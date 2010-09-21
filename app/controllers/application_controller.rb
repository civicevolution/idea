# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_application_view_path
  before_filter :authorize, :except => [ :login, :proposal, :join_proposal_team, :get_templates ]
  before_filter :set_initiative_id
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  protect_from_forgery # :except => [:upload_member_photo]

  
  
  
  def set_initiative_id
    case request.subdomains.first
      when /^2029-staff$/i
        params[:_initiative_id] = 1
      when /^2029$/	
        params[:_initiative_id] = 2
      when /^cgg$/	
        params[:_initiative_id] = 1
      when /^demo$/i
        params[:_initiative_id] = 3
      when /^ncdd$/i
        params[:_initiative_id] = 6
      else	
        params[:_initiative_id] = 5
    end
    
    #logger.warn "request.subdomains.first: #{request.subdomains.first}, params[:_initiative_id]: #{params[:_initiative_id]}"
  end
  

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def set_application_view_path
    #logger.warn "v2 set_application_view_path, request.subdomains.first: #{request.subdomains.first}"
    #self.prepend_view_path("app/views/uos") if request.subdomains.first == 'uos'
    case request.subdomains.first
      when 'ncdd'
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/ncdd") ])
      when 'civic'
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/civic") ])
      when '2029', 'cgg'  
        self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/cgg") ])
    end
    #self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/ncdd") ]) if request.subdomains.first == 'uos'
    #self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/") ]) if request.subdomains.first == 'demo'
    #self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/cgg") ]) if !request.subdomains.first.match(/t?2029/).nil? || !request.subdomains.first.match(/t?cgg/).nil?
    #self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/cgg") ])
    
#    if !request.subdomains.first.match(/^2029$/).nil? || 
#        !request.subdomains.first.match(/^2029-staff$/).nil? || 
#        !request.subdomains.first.match(/^cgg$/).nil? ||
#        !request.subdomains.first.match(/^ncdd$/).nil? ||
#        !request.subdomains.first.match(/^demo$/).nil?
#      self.prepend_view_path([ ::ActionView::ReloadableTemplate::ReloadablePath.new(Rails::root.to_s + "/app/views/cgg") ]) 
#    end
    
   # logger.debug "+++++ ActionController::Base.set_application_view_path based on subdomain: #{request.subdomains.first}"
  #  ActionController::Base.application_view_path = request.subdomains.first # IF you happen to use subdomains to switch (i.e. store.app.com, inventory.app.com)
  #  logger.debug "+++++ ActionController::Base.application_view_path: #{ActionController::Base.application_view_path}"
  end

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
