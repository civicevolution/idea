class PlanController < ApplicationController
  layout "welcome", :only => [:suggest_new_idea]
  
  def index
    logger.debug "\n\n******************************************\nStart plan/index\n"
    begin
      @team = Team.includes(:questions).find(params[:id])
    rescue
      render :template => 'team/proposal_not_found', :layout=> 'welcome'
      return
    end
    
    # verify acccess to this team
    allowed,message = InitiativeRestriction.allow_action(@team.initiative_id, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        flash[:pre_authorize_uri] = request.request_uri
        flash[:notice] = "Please sign in"
        render :template => 'welcome/must_sign_in', :layout => 'welcome'
        return
      else
        render :template => 'idea/private_page'
        return
      end
    end
    
    
    @team.get_talking_point_ratings(@member)
    @team['org_member'] = Member.find_by_id(@team.org_id)
    
    render :index#, :layout=> false
    
    logger.debug "\n\nEnd plan/index\n******************************************\n"
    logger.flush
    #logger.auto_flushing = 1
  end
  
  def suggest_new_idea
    logger.debug "show form for suggest_new_idea"
    @proposal_idea = ProposalIdea.new params[:proposal_idea] unless @proposal_idea
    respond_to do |format|
      format.html { render :template => "plan/suggest_new_idea", :layout=> 'welcome', :locals=>{:proposal_idea=>@proposal_idea} }
      format.js
    end
    
  end
  
  def submit_proposal_idea
    logger.debug "plan#submit_proposal_idea, params: #{params.inspect}"
    
    restrictions_test,message = InitiativeRestriction.allow_action(params[:_initiative_id], 'suggest_idea', @member)

    @proposal_idea = ProposalIdea.new params[:proposal_idea]
    if !restrictions_test
      logger.warn "failed restrictons test with message: #{message}"
      @saved = false
      @proposal_idea.errors.add(:base, message)
    else
      @proposal_idea.member_id = @member.id
      @proposal_idea.initiative_id = params[:_initiative_id]
      @saved = @proposal_idea.save
      #@saved = true
      #@proposal_idea.id = 1234
    end
    
    if @saved
      #@proposal_idea = ProposalIdea.find(1)
      ProposalMailer.delay.submit_receipt(@member, @proposal_idea, params[:_app_name] )
      ProposalMailer.delay.review_request(@member, @proposal_idea, request.env["HTTP_HOST"], params[:_app_name] )
    end
    
    respond_to do |format|
      if @saved
        format.html { render :template => "plan/acknowledge_proposal_idea", :layout => 'welcome' }
        format.js
        
      else
        format.html do
          suggest_new_idea
          logger.debug "back from suggest_new_idea in submit_proposal_idea"
        end
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end
  end
  

  protected
  
  PLAN_CONTROLLER_PUBLIC_METHODS = ['index']
  #, 'bsd', 'guidelines', 'get_templates', 'report', 'post_content_report', 'request_help', 'request_help_post', 'tooltips','invite']
  
  def authorize
    #debugger
    unless PLAN_CONTROLLER_PUBLIC_METHODS.include? request[:action]
      # do this except for public methods
      if (@member.nil? || @member.id == 0 )
        if request.xhr?
          respond_to do |format|
            case request[:action]
              when 'create_answer'
                act = 'add or edit an answer'
              when 'create_comment'
                act = 'add or edit a comment'
              when 'create_brainstorm_idea'
                act = 'add a brainstorming idea'
              else
                act = 'continue'
            end
            format.json { render :text => [ {'Sign in required'=> [act]} ].to_json, :status => 409 }
          end
          return
        else
          flash[:pre_authorize_uri] = request.request_uri
          flash[:notice] = "Please sign in"
          render :template => 'welcome/must_sign_in', :layout => 'welcome'
          
        end
      end
    end
    if @member.nil? 
      @member = Member.new :first_name=>'Unknown', :last_name=>'Visitor'
      @member.id = 0
      @member.email = ''
      @member.last_visit_ts = Time.local(2012,2,23)
    end
  end



end
