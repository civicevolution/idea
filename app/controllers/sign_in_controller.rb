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

  def reset_password
  end

  def change_password
  end

end
