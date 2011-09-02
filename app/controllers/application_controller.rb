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

  rescue_from Exception, :with => :error_generic
  rescue_from ActionController::RoutingError, :with => :render_404
  
  def error_generic(exception)
    logger.error "Error detected: #{exception.message}"
    gems_line_ctr = 0
    exception.backtrace.each do |line|
      if line.match(/\/gems\//)
        gems_line_ctr += 1
        break if gems_line_ctr > 5
      else
        logger.error "#{line}\n"
      end
    end
    begin
      member = Member.find_by_id(session[:member_id])
      respond_to do |format|
        format.js { render :template => "errors/generic_error", :locals => {:member=>member, :exception => exception } }
        format.html {render :template=> 'errors/generic_error', :layout=>false, :locals => {:member=>member, :exception => exception} } if request.xhr?
        format.html {render :template=> 'errors/generic_error', :layout=>'plan', :locals => {:member=>member, :exception => exception} }
      end
      notify_airbrake(exception) unless Rails.env == 'development'
    rescue Exception => exception
      logger.error "Error detected during error handling: #{exception.message}"
      exception.backtrace[0].split(/:in\s/).each{ |line| puts logger.error ":in #{line}"}
    end
  end

  def render_404
    @member = member = Member.find_by_id(session[:member_id])
    render :template=> 'errors/404_not_found', :layout=>'welcome', :locals => {:member=>member, :path=> request.url }
  end
  
  
  
    
  protected
  
  
  
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
      logger.silence(3) do
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
          @member = Member.new :first_name=>'Unknown', :last_name=>'Visitor'
          @member.id = 0
          @member.email = ''
          @member.last_visit_ts = Time.now #.local(2012,2,23)
        else
          if params[:date]
            time_stamp = params[:date].scan(/\d\d/)
            session[:last_visit_ts] = Time.local(time_stamp[0], time_stamp[1], time_stamp[2])
          end
          session[:last_visit_ts] ||= Time.now #.local(2012,7,29)
          @member.last_visit_ts = session[:last_visit_ts]
        end
      end
    end

    def authorize
      logger.silence(3) do
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
  
  
end
