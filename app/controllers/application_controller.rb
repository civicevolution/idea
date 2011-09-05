# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_application_personality, :except => [ :logo, :rss ]
  before_filter :add_member_data, :except => [ :logo, :rss ]
  before_filter :authorize, :except => [ :sign_in_form, :sign_in_post, :login, :proposal, :logo, :rss]
  
  helper_method :sign_out, :sign_in_post, :sign_in_form

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


  def sign_in_form
    # show the sign in form
    flash.keep # keep the info I saved till I successfully process the sign in
    render :template => 'sign_in/sign_in_form', :layout => 'plan'
  end

  def sign_in_post
    logger.debug "sign_in_post #{params.inspect}"
    @member = Member.authenticate(params[:email], params[:password])

    if @member
      session[:member_id] = @member.id
      if params[:stay_signed_in]
       request.session_options = request.session_options.dup
       request.session_options[:expire_after]= 30.days
       #request.session_options.freeze
      end
      
      if params[:date]
        time_stamp = params[:date].scan(/\d\d/)
        session[:last_visit_ts] = Time.local(time_stamp[0], time_stamp[1], time_stamp[2])
      end
      session[:last_visit_ts] ||= Time.now #.local(2012,7,29)
      @member.last_visit_ts = session[:last_visit_ts]
      
      respond_to do |format|
        format.html{
          if flash[:params]
            # I came here through a redirect after user was told to sign in
            # Assign the params from initial request that are stored in flash
            flash[:params].each_pair{|key,val| params[key] = val }
            if flash[:fullpath]
              redirect_to flash[:fullpath]
            else
              send params[:action] # this will execute the method stored in params[:action]
            end
          else
            redirect_to home_path
          end
        }
        format.js{
          logger.debug "Respond to sign in form post from UJS"
          if flash[:params]
            # I came here through a redirect after user was told to sign in
            # Assign the params from initial request that are stored in flash
            flash[:params].each_pair{|key,val| params[key] = val }
            send params[:action] # this will execute the method stored in params[:action]
          else
            redirect_to home_path
          end
          
        }
      end
    else # no member was retrieved with password and email
      flash.keep # keep the info I saved till I successfully process the sign in
      logger.debug "No valid member for email/pwd"
      flash[:notice] = "Invalid email/password combination"
      respond_to do |format|
        format.html { redirect_to sign_in_all_path(:controller=> params[:controller]) }
        format.js { render :controller=>'sign_in', :action=>'index' }
        #format.any # specify what you want to happen here or it will look for template with the appropriate name
      end
    end # end if member
  end

  def sign_out
    session[:member_id] = nil
    flash[:notice] = "Signed out"
    redirect_to :controller=> 'welcome', :action => "index"
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
          force_sign_in
        end
      end
    end

  def force_sign_in
    respond_to do |format| 
      format.js { 
        flash[:params] = request.params
        flash[:fullpath] = request.fullpath unless request.method.match(/POST/i)
        flash[:notice] = "Please sign in to continue"
        render :template => 'sign_in/sign_in_form.js', :layout => false#, :status => 409
      }
      format.html {
        # this shouldn't be accessed as all ajax is now via UJS, as js
        render :template=> 'errors/generic_error', :layout=>false, :locals => {:member=>member, :exception => exception} 
      } if request.xhr?
      format.html {
        flash[:params] = request.params
        flash[:fullpath] = request.fullpath unless request.method.match(/POST/i)
        flash[:notice] = "Please sign in to continue"
        redirect_to sign_in_all_path(:controller=> params[:controller])
      }
    end
  end
  
end
