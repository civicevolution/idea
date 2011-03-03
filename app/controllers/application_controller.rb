# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_application_personality, :except => [ :logo, :rss ]
  before_filter :add_member_data, :except => [ :logo, :rss ]
  before_filter :authorize, :except => [ :login, :proposal, :logo, :rss]

  
  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  protect_from_forgery :except => [:load_report] # :except => [:upload_member_photo]

  # put most generic exception at the top

  rescue_from Exception, :with => :error_generic unless Rails.env == 'development'
  rescue_from ActionController::RoutingError, :with => :render_404
  
  def error_generic(exception)
    log_error(exception)
    begin
      member = Member.find_by_id(session[:member_id])
      render :template=> 'errors/generic_error', :layout=>'welcome', :locals => {:member=>member}
      ErrorMailer.deliver_error_report(member, exception, request.env["HTTP_HOST"], params[:_app_name] )
    rescue
      log_error("XXXX error_generic Had an error trying to report an error with email and custom error page")
    end
  end

  def render_404
    @member = member = Member.find_by_id(session[:member_id])
    render :template=> 'errors/404_not_found', :layout=>'welcome', :locals => {:member=>member, :path=> request.host + request.request_uri }
  end
  
  
  
  def check_member_team_access(team_id)
    logger.debug "check_member_team_access for team id #{team_id}"
    # check that member has access to this team
    @member = Member.find_by_id(session[:member_id])
    logger.debug "Member is #{@member.first_name}"
    @team = @member.teams.find_by_id( team_id )
  end
    
  protected
  
    def logger
      if params[:monitor] == 'true' && params[:controller] == 'welcome' && params[:action] == 'index'
        # ignore monitoring requests
        RAILS_MONITOR_NULL_LOGGER
      else
        Rails.logger
      end
    end
  
  
    def set_application_personality
      case request.subdomains.first
        when /^2029-staff$/i, /^cgg$/
          params[:_initiative_id] = 1
          params[:_app_name] = '2029 and Beyond for Staff'
          self.prepend_view_path([ Rails::root.to_s + "/app/views/cgg" ])
        when /^2029$/	
          params[:_initiative_id] = 2
          params[:_app_name] = '2029 and Beyond'
          self.prepend_view_path([ Rails::root.to_s + "/app/views/cgg" ])
        when 'game'
          params[:_initiative_id] = 1
          params[:_app_name] = '2029 and Beyond Staff GAME'
          self.prepend_view_path([ Rails::root.to_s + "/app/views/cgg" ])
        when /^demo$/i
          params[:_initiative_id] = 3
          params[:_app_name] = 'CivicEvolution Demo'
          self.prepend_view_path([ Rails::root.to_s + "/app/views/cgg" ])
        else	
          params[:_initiative_id] = 5
          params[:_app_name] = 'CivicEvolution'
          self.prepend_view_path([ Rails::root.to_s + "/app/views/civic" ])
      end
    end
  
  
    def add_member_data
      if params[:_mlc]
        @member = MemberLookupCode.get_member(params[:_mlc], {:target_url=>request.request_uri} )
        if @member.nil?
          if session[:_mlc] != params[:_mlc] || session[:member_id].nil?
            #render :controller=>'welcome', :action=>'request_new_access_code'
            render :template=>'welcome/request_new_access_code', :layout=>'welcome'
            flash[:pre_request_access_code_uri] = request.request_uri #.sub(/\?.*/,'')
            return
          else
            @member = Member.find_by_id(session[:member_id]);
          end
        else
          session[:member_id] = @member.id
          session[:_mlc] = params[:_mlc]
        end

      else
        @member = Member.find_by_id(session[:member_id]);
      end
      
      if @member.nil?
        # session is no good
        session[:member_id] = nil
      #else
      #  @mem_teams = TeamRegistration.find(:all,
      #    :select => 't.id, t.title, t.launched',  
      #    :conditions => ['member_id = ?', @member.id],
      #    :joins => 'as tr inner join teams t on tr.team_id = t.id' 
      #  )
      end
    end

    def authorize
      unless Member.find_by_id(session[:member_id])
        if request.xhr? || params[:post_mode] == 'ajax'
          # send back a simple notice, do not redirect
          m = Member.new
          m.errors.add(:base, 'You must sign in to continue')
          render :text => [m.errors].to_json, :status => 401
        else
          flash[:pre_authorize_uri] = request.request_uri
          flash[:notice] = "Please sign in"
          render :template => 'welcome/must_sign_in', :layout => 'welcome'
          #redirect_to :controller => 'welcome' , :action => 'not_signed_in'
        end
      end
    end
  
  
end
