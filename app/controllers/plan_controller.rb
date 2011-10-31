class PlanController < ApplicationController
  layout "plan", :only => [:suggest_new_idea, :review_proposal_idea]
  skip_before_filter :authorize, :only => [ :index, :summary, :suggest_new_idea, :new_content, :get_templates]
  
  def index
    logger.debug "\n\n******************************************\nStart plan/index\n"
    begin
      @team = Team.includes(:questions).find(params[:team_id])
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
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    
    
    @team.get_talking_point_ratings(@member)
    @team['org_member'] = Member.find_by_id(@team.org_id)
    
    render :index, :layout => 'plan'
    
    logger.debug "\n\nEnd plan/index\n******************************************\n"
    logger.flush
    #logger.auto_flushing = 1
  end

  def summary
    logger.debug "\n\n******************************************\nStart plan/summary\n"
    begin
      @team = Team.includes(:questions).find(params[:team_id])
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
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    
    @team.get_talking_point_ratings(@member)

  	@endorsements = Endorsement.includes(:member).order('id ASC').all(:conditions=>['team_id=?',@team.id])

    render :summary, :layout => 'plan'
    ActiveSupport::Notifications.instrument( 'tracking', :event => 'Summary page', :params => params.merge(:member_id => @member.id, :session_id=>request.session_options[:id])) unless @member.nil? || @member.id == 0
    
    logger.debug "\n\nEnd plan/summary\n******************************************\n"
    logger.flush
    #logger.auto_flushing = 1
  end
  
  def new_content
    
    # verify acccess to this team
    allowed,message = InitiativeRestriction.allow_actionX({:team_id => params[:team_id]}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    
    time_stamp = params[:time_stamp] 
    if time_stamp
      time_stamp = time_stamp.scan(/\d\d/)
      @last_visit = Time.local(time_stamp[0], time_stamp[1], time_stamp[2])
    else
      @last_visit = @member.last_visit_ts      
      @last_visit= @last_visit.advance(:days => -7) unless @member.id != 0
    end

    @team = Team.includes(:questions).find(params[:team_id])
    #@questions = Question.where("team_id = :team_id", :team_id => params[:team_id])
    
    @talking_points = TalkingPoint.where("question_id IN (:question_ids) AND updated_at >= :last_visit", :question_ids => @team.questions.map(&:id), :last_visit => @last_visit )
    @talking_points.each{|tp| tp['new'] = true }
    
    @comments = Comment.includes(:author).where("team_id = :team_id AND created_at >= :last_visit", :team_id => params[:team_id], :last_visit => @last_visit)
    
    tps_i_need = @comments.map{ |c| c.parent_type == 13 ? c.parent_id : nil}.compact.uniq - @talking_points.map(&:id)

    if tps_i_need.size > 0
      @talking_points  = @talking_points + TalkingPoint.find(tps_i_need)
    end
    
    TalkingPoint.add_my_ratings_and_prefs(@talking_points,@member)

    Comment.set_question_id_child_comments(@comments)
    
    render :new_content, :layout => 'plan'
    ActiveSupport::Notifications.instrument( 'tracking', :event => 'New content page', :params => params.merge(:member_id => @member.id)) unless @member.nil? || @member.id == 0
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
        @team.create_team_plan_page()

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

  def get_templates

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




    # the templates are built in get_templates.js
    render :template => 'plan/get_templates.html' #, :content_type => 'application/javascript'
    
    
=begin    
    
    render_to_string( :partial => 'plan/comment.html', :object => @comment) 

strs.push render_to_string( :partial => 'plan/comment.html', :object => @comment,
  :locals => { :item => Item.new, :down => 0, :up => 0,  :rated => 0, :mode=>'templ'})
    
    @team = Team.new(:com_criteria=>'4..7', :res_criteria=>'3..8')
    @question = Question.new(:text => 'Question for template', :created_at => old_ts, :updated_at => old_ts, :answer_criteria=>'5..15',:idea_criteria=>'6..12')
    @question.id = 1

           
    #@comment[:member_id] = @member.id
    #@comment[:pic_id] = 10011
    #@comment[:text] = ''
    #@comment[:my_vote] = 0
    #@comment[:up] = 0
    #@comment[:down] = 0
    #@comment[:par_id] = 0
    #@comment[:sib_id] = 123
    #@comment[:item_id] = 123
    #@comment.member_id = 0
    #@resources = [ Resource.new ] 
    #@authors = [Member.new(:first_name=>'J', :last_name=>'Public') ]
    #@authors[0].id = 0
    #@comments = []
    #@new_coms = @coms = 0
    #@member = Member.new
    #@member.id = 0
    #
    #strs.push render_to_string( :partial => 'comment', :object => @comment,
    #  :locals => { :item => Item.new, :down => 0, :up => 0,  :rated => 0, :mode=>'templ'})
    #
    #strs.push '<hr/><h3>add_comment_combined</h3><hr/>'
    #strs.push render_to_string(:partial => 'add_comment_combined', :locals => { :id => 1, :label=>'Please add your comment'})
    #strs.push '<hr/><h3>add_answer</h3><hr/>'
    #strs.push render_to_string(:partial => 'add_answer', :locals => { :question=>@question })
    #strs.push '<hr/><h3>add_bs_idea</h3><hr/>'
    #strs.push render_to_string(:partial => 'add_bs_idea', :locals => { :question=>@question })
    #
    #bs_idea = BsIdea.new(:member_id => @member.id, :created_at => old_ts, :updated_at => newer_ts)
    #bs_idea.item_id = 1
    #bs_idea['new_coms']  = bs_idea['coms'] = 0
    #strs.push '<hr/><h3>bs_idea</h3><hr/>'
    #strs.push render_to_string( :partial=> 'bs_idea', :object=>bs_idea, :locals=>{:mode=>'templ', :coms=>'t'} )
    #
    #answer = Answer.new :text=>'', :ver=>1, :item_id=>0
		#answer['my_vote'] = answer['average'] = answer['count'] = 3
    #strs.push '<hr/><h3>answer</h3><hr/>'
    #strs.push render_to_string( :partial => 'answer', :object=>answer, :locals=> {:question=> @question, :title=>'Current answer', :def_ans=>nil, :is_def_ans=>false} )
    #
    #
    ##strs.push '<hr/><h3>chat message</h3><hr/>'
    ##strs.push render_to_string(:partial => '/team/chat')
    #
    #@endorsements = [Endorsement.new(:member_id=>1, :updated_at=> old_ts)]
    #@member = Member.find(1)
  	#@endorsers = [ @member ]
    #strs.push '<hr/><h3>endorsement</h3><hr/>'
    #strs.push render_to_string( :partial=> 'endorsements')
=end     
    
  end

end
