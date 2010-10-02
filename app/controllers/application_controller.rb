# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_application_personality
  before_filter :authorize, :except => [ :login, :proposal, :join_proposal_team, :get_templates ]
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  protect_from_forgery # :except => [:upload_member_photo]

  def set_application_personality
    case request.subdomains.first
      when /^2029-staff$/i, /^cgg$/
        params[:_initiative_id] = 1
        params[:_app_name] = '2029 and beyond for Staff'
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/cgg") ])
      when /^2029$/	
        params[:_initiative_id] = 2
        params[:_app_name] = '2029 and beyond'
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/cgg") ])
      when 'ncdd'
        params[:_initiative_id] = 6
        params[:_app_name] = 'NCDD'
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/ncdd") ])
      when /^demo$/i
        params[:_initiative_id] = 3
        params[:_app_name] = 'CivicEvolution Demo'
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/civic") ])
      else	
        params[:_initiative_id] = 5
        params[:_app_name] = 'CivicEvolution'
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/civic") ])
    end
  end
  

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  def check_member_team_access(team_id)
    logger.debug "check_member_team_access for team id #{team_id}"
    # check that member has access to this team
    @member = Member.find_by_id(session[:member_id])
    logger.debug "Member is #{@member.first_name}"
    @team = @member.teams.find_by_id( team_id )
  end
    
  protected
  
    def authorize
      unless Member.find_by_id(session[:member_id])
        if request.xhr? || params[:post_mode] == 'ajax'
          # send back a simple notice, do not redirect
          m = Member.new
          m.errors.add(:base, 'You must sign in to continue')
          render :text => [m.errors].to_json, :status => 500
        else
          flash[:pre_authorize_uri] = request.request_uri
          flash[:notice] = "Please sign in"
          render :template => 'welcome/must_sign_in', :layout => 'welcome'
          #redirect_to :controller => 'welcome' , :action => 'not_signed_in'
        end
      end
    end
  
  
end
