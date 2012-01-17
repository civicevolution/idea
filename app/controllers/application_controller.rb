# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :set_application_personality, :except => [ :logo, :rss ]
  before_filter :add_member_data, :except => [ :logo, :rss ]
  before_filter :authorize, :except => [ :sign_in_form, :sign_in_post, :temp_join_save_email, :login, :proposal, :logo, :rss]
  
  helper_method :sign_out, :sign_in_post, :sign_in_form, :temp_join_save_email

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
    render :template=> 'errors/404_not_found', :layout=>'plan', :locals => {:member=>member, :path=> request.url }
  end


  def sign_in_form
    # show the sign in form
    flash.keep # keep the info I saved till I successfully process the sign in
    render :template => 'sign_in/sign_in_form', :layout => 'plan'
  end

  def sign_in_post
    logger.debug "sign_in_post"
    if params[:sign_in] || params[:email].length > 0 && params[:password].length > 0
      process_sign_in_post
    elsif params[:email_join].length > 0
      process_join_post
    else
      process_sign_in_post
    end
  end
  
  def process_join_post
    logger.debug "process_join_post for #{params[:email_join]}"
    flash.keep
    respond_to do |format|
      if Member.email_in_use(params[:email_join])
        format.js { render :template => "sign_in/join_email_address_in_use", :locals => {:email=>params[:email]} }
        format.html {render :template=> 'sign_in/join_email_address_in_use', :layout=>'plan', :locals => {:email=>params[:email]} }
      else  
        format.js { render :template => "sign_in/join_email_address_ok", :locals => {:email=>params[:email]} }
        format.html {render :template=> 'sign_in/join_email_address_ok', :layout=>'plan', :locals => {:email=>params[:email]} }
      end
    end
  end
  
  def temp_join_save_email
    code = EmailLookupCode.get_code(params[:email])
    session[:code] =  code
    
    # send the email with this code
    url = new_profile_form_url(:code => code)
    MemberMailer.send_profile_link(params[:email], url, params[:_app_name] ).deliver
    #I should still have flash params and I should execute them
    if flash[:params]
      ppa = PreliminaryParticipantActivity.create :init_id => params[:_initiative_id], :email=> EmailLookupCode.get_email(session[:code]), :flash_params => flash[:params]
    else
      ppa = nil
    end
    respond_to do |format|
      if ppa.nil? || ppa.errors.empty?
        format.js { 
          # if js, just close the form, otherwise determine what to show
          params[:action] = flash[:params][:action] if flash[:params]
          params[:input_type] = flash[:params][:input_type] if flash[:params]
          render :template => 'sign_in/close_temp_join_save_email' 
        }
        format.html {
          params[:action] = flash[:params][:action] if flash[:params]
          params[:team_id] = flash[:params][:team_id] if flash[:params]
          msg, redirect_url = get_redirect
          render :template => 'sign_in/acknowledge_preliminary_participation_and_redirect.html', :locals => {:msg => msg, :redirect_url => redirect_url}, :layout => 'plan'
        }
      else
        format.js { }
        format.html { render 'sign_in/temp_join_error' }
      end
    end    
  end
  
  def process_sign_in_post
    @member = Member.authenticate(params[:email], params[:password])

    if @member
      session[:member_id] = @member.id
      session.delete :code
      session.delete :_mlc
      session.delete :last_visits
      if params[:stay_signed_in]
       request.session_options = request.session_options.dup
       request.session_options[:expire_after]= 30.days
       #request.session_options.freeze
      end
      
      session[:last_visits] ||= {}
      if flash[:params] && flash[:params][:team_id] # I can only set the last_visit for a team if I know the team_id
        if params[:date]
          time_stamp = params[:date].split('-') # 11-21-2011
          session[:last_visits][flash[:params][:team_id]] = Time.local(time_stamp[2], time_stamp[0], time_stamp[1])
        else
          last_event = ParticipantStats.where(:member_id => @member.id, :team_id => flash[:params][:team_id])
          session[:last_visits][flash[:params][:team_id]] = last_event[0].nil? ? Time.now - 7.days : last_event[0].updated_at
        end
      end
      @member.last_visits = session[:last_visits]

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
            redirect_to params[:controller] != "admin" ? home_path : admin_path
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
            #render 'redirect_to_home_page'
            render 'sign_in/reload.js'
          end
        }
      end
    else # no member was retrieved with password and email
      flash.keep # keep the info I saved till I successfully process the sign in
      logger.debug "No valid member for email/pwd"
      flash[:notice] = "Invalid email/password combination"
      respond_to do |format|
        format.html { redirect_to sign_in_all_path(:controller=> params[:controller], :email=>params[:email]) }
        format.js { render 'sign_in/sign_in_form' }
      end
    end # end if member
  end

  def sign_out
    session.delete :member_id
    session.delete :code
    session.delete :_mlc
    session.delete :last_visits
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
        when /^skyline$/i
          params[:_initiative_id] = 5
          params[:_app_name] = 'Skyline Voices'
          self.prepend_view_path([ Rails::root.to_s + "/app/views/skyline" ])
        when /^live$/i
          params[:_initiative_id] = 7
          params[:_app_name] = 'CivicEvolution Live'
          self.prepend_view_path([ Rails::root.to_s + "/app/views/live" ])
        else	
          params[:_initiative_id] = 6
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
              render :template=>'members/request_new_access_code', :layout=>'plan'
              flash[:pre_request_access_code_uri] = request.request_uri #.sub(/\?.*/,'')
              return
            else
              @member = Member.find_by_id(session[:member_id]);
            end
          else
            session[:member_id] = @member.id
            if session[:_mlc] != params[:_mlc] # only record the first time this code is used
              ActiveSupport::Notifications.instrument( 'tracking', :event => 'Visit with _mlc', :params => params.merge(:member_id => @member.id))
            end
            session[:_mlc] = params[:_mlc]
          end

        else
          @member = Member.find_by_id(session[:member_id]);
        end
        session[:last_visits] ||= {}
        if @member.nil?
          # session is no good
          session[:member_id] = nil
          @member = Member.new :first_name=>'Unknown', :last_name=>'Visitor'
          @member.id = 0
          @member.email = ''
          session[:last_visits][params[:team_id]] = Time.now - 7.days unless params[:team_id].nil?
        else
          if params[:team_id] # I can only set the last_visit for a team if I know the team_id
            session[:last_visits] = {} if session[:last_visits].nil?
            if params[:date]
              time_stamp = params[:date].split('-') # 11-21-2011
              session[:last_visits][params[:team_id]] = Time.local(time_stamp[2], time_stamp[0], time_stamp[1])
            else
              # update last visit for this team only if there is no current timestamp
              if session[:last_visits][params[:team_id]].nil?
                last_event = ParticipantStats.where(:member_id => @member.id, :team_id => params[:team_id])
                session[:last_visits][params[:team_id]] = last_event[0].nil? ? Time.now - 7.days : last_event[0].updated_at
              end
            end
          end
        end
        @member.last_visits = session[:last_visits]
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
    activity_was_queued = false
    if session[:member_id].nil? && !session[:code].nil?
      # this is an action by a user with a preliminary email account
      # for selected actions, store the params with the email
      email_account_actions = [ 'rate_talking_point', 'prefer_talking_point','what_do_you_think',
          'create_comment_comment','create_talking_point_comment','add_endorsement','update_worksheet_ratings','submit_proposal_idea']
      if email_account_actions.include?( params[:action])
        PreliminaryParticipantActivity.create :init_id => params[:_initiative_id], :email=> EmailLookupCode.get_email(session[:code]), :flash_params => params
        activity_was_queued = true
      end
    end
    respond_to do |format| 
      if activity_was_queued
        format.js {
           render :template => 'sign_in/acknowledge_preliminary_participation.js' }
        format.html {
          msg, redirect_url = get_redirect
          render :template => 'sign_in/acknowledge_preliminary_participation_and_redirect.html', :locals => {:msg => msg, :redirect_url => redirect_url}, :layout => 'plan'
           }
      else
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
  
  def get_redirect
    case params[:action]
    	when /what_do_you_think/
    	  if params[:input_type] == "talking_point"
    	    msg = 'Your talking point was recorded.'
    	  else
    	    msg = 'Your comment was recorded.'
    	  end
    		redirect_url = question_worksheet_path(params[:question_id])
    	when /create_comment_comment/
    	  msg = 'Your comment was recorded.'
    		redirect_url = comment_comments_path(params[:comment_id])
    	when /create_talking_point_comment/
    	  msg = 'Your comment was recorded.'
    		redirect_url = talking_point_comments_path(params[:talking_point_id])
    	when /add_endorsement/
    	  msg = 'You endorsement was recorded.'
    		redirect_url = plan_path(params[:team_id])
    	when /update_worksheet_ratings/
    	  msg = 'Your ratings were recorded.'
    		redirect_url = question_worksheet_path(params[:question_id])
    	when /submit_proposal_idea/
    	  msg = 'Your proposal suggestion was recorded.'
    		redirect_url = home_path
    end  
    return msg, redirect_url  
  end
  
end
