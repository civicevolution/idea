class PlanController < ApplicationController
  layout "plan", :only => [:suggest_new_idea, :review_proposal_idea]
  skip_before_filter :authorize, :only => [ :index, :summary, :suggest_new_idea, :new_content, :get_templates, :test]

  def test
    render :template=>'plan/test', :layout=> 'test'
  end

  def summary
    logger.debug "\n\n******************************************\nStart plan/summary\n"
    begin
      @team = Team.includes(:questions).find(params[:team_id])
      #@team = Team.includes(:questions => :curated_talking_points).find(params[:team_id])
      raise 'Team is no longer accessible' if @team.nil? || @team.status == 'closed'
    rescue
      render :template => 'team/proposal_not_found', :layout=> 'plan'
      return
    end
    
    # verify acccess to this team
    allowed,message = InitiativeRestriction.allow_actionX({:team_id => params[:team_id]}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private', :locals => {:message=>message} }
          format.html { render 'shared/private', :layout => 'plan', :locals => {:message=>message} }
        end
      end
      return
    end

    @team.assign_question_stats(@member.id)

    # eager load the curated talking points and attach them to the questions in order as question.curated_talking_points
    @team.include_curated_talking_points

    # get default answers if needed
    def_ids = @team.questions.select{|q| q.curated_tp_ids.nil? || q.curated_tp_ids.strip == ''}.map(&:default_answer_id)
    @default_answers = DefaultAnswer.select('id,checklist').where(:id=>def_ids) unless def_ids.size == 0

    @participant_stats = ParticipantStats.find_by_member_id_and_team_id(@member.id,@team.id) || ParticipantStats.new

  	@endorsements = Endorsement.includes(:member).order('id ASC').all(:conditions=>['team_id=?',@team.id])

    @channels = ["_auth_team_#{@team.id}"]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    render :summary, :layout => 'plan'
    ActiveSupport::Notifications.instrument( 'tracking', :event => 'Summary page', :params => params.merge(:member_id => @member.id, :session_id=>request.session_options[:id])) unless @member.nil? || @member.id == 0
    
    logger.debug "\n\nEnd plan/summary\n******************************************\n"
    logger.flush
    #logger.auto_flushing = 1
  end
  
  def suggest_new_idea
    logger.debug "show form for suggest_new_idea"
    @proposal_idea = ProposalIdea.new params[:proposal_idea] unless @proposal_idea
    respond_to do |format|
      format.html { render :template => "plan/suggest_new_idea", :layout=> 'plan', :locals=>{:proposal_idea=>@proposal_idea} }
      format.js
    end
    
  end
  
  def submit_proposal_idea
    logger.debug "plan#submit_proposal_idea, params: #{params.inspect}"
    
    @proposal_idea = ProposalIdea.new params[:proposal_idea]
    @proposal_idea.member = @member

    respond_to do |format|
      if @proposal_idea.save
        ProposalMailer.delay.submit_receipt(@member, @proposal_idea, params[:_app_name] )
        ProposalMailer.delay.review_request(@member, @proposal_idea, request.env["HTTP_HOST"], params[:_app_name] )
        format.html { render :template => "plan/acknowledge_proposal_idea", :layout => 'plan' }
        format.js
      else
        # what do I do if there is an error saving the proposal?
        format.html do
          suggest_new_idea
          logger.debug "back from suggest_new_idea in submit_proposal_idea"
        end
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end
  end
  
  def review_proposal_idea
    logger.debug "review_proposal_idea for id: #{params[:id]}"
    @proposal = ProposalIdea.find(params[:id])
    @submittor = Member.find_by_id(@proposal.member_id)
    respond_to do |format|
      if @submittor.nil? 
        format.html { render :text => "Please ignore this suggested idea -- the person that submitted this proposal is no longer a member", :layout => 'plan' } 
      else
        format.html { render :action => "review_proposal_idea", :layout => 'plan' } 
      end
    end
  end

  def approve_proposal_idea
    # publish this idea and notify the person that submitted the idea
    @proposal_idea = ProposalIdea.find(params[:id])
    @submittor = Member.find(@proposal_idea.member_id)
    
    # convert the idea into a team
    
    admin = Member.find_by_id(session[:member_id]);
    if !admin.nil? && admin.email == 'brian@civicevolution.org'
    
      logger.debug "create_team_from_proposal_idea for id: #{params[:id]}"
      #id refers to the proposal
      @proposal_idea = ProposalIdea.find(params[:id])

      if !@proposal_idea.launched
    
        # create a team record
        @team = Team.new :initiative_id => @proposal_idea.initiative_id, :org_id=>@proposal_idea.member_id, :title=>@proposal_idea.title, 
          :archived=>false, :problem_statement=>'', :solution_statement=>@proposal_idea.text, :min_members=>4, :max_members=>25
        @team.save
        
        @team.member = admin # so create team idea page can set the launched status = true
        
        # create the plan page
        @team.create_team_plan_page(@proposal_idea.id)

        @proposal_idea.update_attribute('launched',true)
        
        #notify the author
        @host = request.env["HTTP_HOST"]
        ProposalMailer.delay.approval_notice(@submittor, @proposal_idea, @team, @host )

        render :action => "proposal_idea_published", :layout => 'plan'
      else
        logger.debug "This proposal: #{@proposal_idea} has already been converted into a team"
        render :text=> "This proposal: #{@proposal_idea} has already been converted into a team", :layout => 'plan'
      end
    else
      render :action => "must_be_admin", :layout => 'plan'
    end
  end
  
  def proposal_pic
    
  end

  def submit_proposal
    allowed,message = InitiativeRestriction.allow_actionX({:team_id => params[:team_id]}, 'submit_proposal', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'submit_proposal_not_allowed', :locals => {:message=>message} }
          format.html { render 'submit_proposal_not_allowed', :layout => 'plan', :locals => {:message=>message} }
        end
      end
      return
    end

    @team = Team.find(params[:team_id])
    if params[:step].nil?
      render :action=> 'submit_proposal', :layout => 'plan'
      return
    else
      submit_request = ProposalSubmit.new params[:proposal_submit]
      submit_request.member = @member
      submit_request.member_id = @member.id
      logger.debug "review submit_request: #{submit_request.inspect}"
      if submit_request.save
        AdminReportMailer.delay.submit_proposal(submit_request, @team, @member, request.env['HTTP_HOST'],params[:_app_name] )
        render :action=> 'submit_proposal_acknowledge', :layout => 'plan', :locals=>{:status=>'ok'}
      else
        render :action=> 'submit_proposal_acknowledge', :layout => 'plan', :locals=>{:status=>'fail'}
      end
    end
  end

  def get_templates
    flash.keep
    # Set up all of the data I need for the templates to run
    # Build the templates in the templates.js template which will insert the HTML in script blocks text/html to hide them from browser processing
    # Add the directives to templates.js
    # Compile the templates when this loads into the browser

    old_ts = Time.local(2020,1,1)
    newer_ts = Time.local(2025,1,1)

    @comment = Comment.new(:created_at => old_ts, :updated_at => newer_ts)

    # what do I need to know for the comment template?
    @comment[:anonymous] = 'f'
    @comment.publish = true
    @comment.author = Member.find(1)
    @comment.text = ''
    @comment.id = 0

    @talking_point = TalkingPoint.new(:created_at => old_ts, :updated_at => newer_ts)
    @talking_point.text = ''
    @talking_point.id = 0
    @talking_point.version = 1

    # the templates are built in get_templates.js
    render :template => 'plan/get_templates.html' #, :content_type => 'application/javascript'
    
  end

end
