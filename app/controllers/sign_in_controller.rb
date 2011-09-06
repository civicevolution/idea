class SignInController < ApplicationController
  layout "plan", :except => [:something_else]
  skip_before_filter :authorize
   
  def index
    # show the sign in form
    flash.keep # keep the info I saved till I successfully process the sign in
  end

  def sign_in
    logger.debug "sign_in #{params.inspect}"
    @member = Member.authenticate(params[:email], params[:password])

    if @member
      session[:member_id] = @member.id
      if params[:stay_signed_in]
       request.session_options = request.session_options.dup
       request.session_options[:expire_after]= 30.days
       #request.session_options.freeze
      end
      respond_to do |format|
        format.html{
          debugger
          if flash[:pre_authorize_uri]
            #redirect_to flash[:pre_authorize_uri]
            # owrk out how to send the params
            redirect_to home_path
          else
            redirect_to home_path
          end
        }
        format.js
      end
    else # no member was retrieved with password and email
      flash.keep # keep the info I saved till I successfully process the sign in
      logger.debug "No valid member for email/pwd"
      debugger
      flash[:notice] = "Invalid email/password combination"
      respond_to do |format|
        format.html { redirect_to sign_in_path }
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

  def reset_password_form
  end

  def reset_password_post
    logger.debug "process reset password"
    member = Member.find_by_email(params[:email].downcase)
    respond_to do |format|
      if member.nil?
        format.html {render 'reset_password_failed', :locals => {:email => params[:email] } }
        format.js {}
      else
        # create and store a code for the member
        mcode = MemberLookupCode.get_code(member.id, {:scenario=>'reset password'})
        logger.debug "generate an email to #{member.email} with code: #{mcode}"
        # generate an email to the member

        MemberMailer.delay.reset_password(member,mcode, request.env["HTTP_HOST"]) 

        format.html {render 'reset_password_sent', :locals => {:email => params[:email] } }
        format.js {}
      end
    end
  end
  
  def password_reset_form
    
  end

  def password_reset_post
    # now update the password
    begin
      if @member.nil?
        render :template=> 'sign_in/password_reset_bad_code', :layout=> 'plan'
      else
        if params[:password] != params[:password_repeat]
          flash[:notice] = 'The password you entered twice did not match.'
          redirect_to :action => 'password_reset_form'
          return
        end
        # change the password
        @member.password = params[:password]
        @member.save
        respond_to do |format|
          format.js { }  
          format.html { redirect_to home_path }
        end
      end
    rescue
      render :template=> 'sign_in/password_reset_bad_code', :layout=> 'plan'
    end
  end
  
  def join_our_community
    respond_to do |format|
      format.html { render :action => "join_our_community", :layout => false } if request.xhr?  
      format.html { render :action => "join_our_community" }
    end
  end
  

  def change_password
  end

end

