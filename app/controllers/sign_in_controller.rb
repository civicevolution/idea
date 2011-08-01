class SignInController < ApplicationController
  layout "welcome", :except => [:something_else]
  
  def index
    # show the sign in form
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
      if flash[:pre_authorize_uri]
        render :text => "__REDIRECT__=#{flash[:pre_authorize_uri]}"
      end
      
      respond_to do |format|
        format.html do
          uri = session[:original_uri]
          session[:original_uri] = nil
          if uri
            redirect_to :uri
          else
            redirect_to :controller=> 'welcome', :action => "index"
          end 
          return          
        end
        format.js
        #format.any # specify what you want to happen here or it will look for template with the appropriate name
      end
      
    else # no member was retrieved with password and email
      logger.debug "No valid member for email/pwd"
      flash.now[:notice] = "Invalid email/password combination"
      respond_to do |format|
        format.html { render :controller=>'sign_in', :action=>'index', :status=>401 }
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

  protected
  
  def authorize
    
  end

end
