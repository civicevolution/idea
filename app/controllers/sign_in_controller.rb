class SignInController < ApplicationController
  layout "plan", :except => [:something_else]
  skip_before_filter :authorize
   

  def reset_password_form
  end

  def reset_password_post
    logger.debug "process reset password"
    member = Member.find_by_email(params[:email].downcase)
    respond_to do |format|
      if member.nil?
        format.html {render 'reset_password_not_found' }
        format.js { render 'reset_password_not_found' }
      else
        # create and store a code for the member
        mcode = MemberLookupCode.get_code(member.id, {:scenario=>'reset password'})
        logger.debug "generate an email to #{member.email} with code: #{mcode}"
        # generate an email to the member

        MemberMailer.delay.reset_password(member,mcode, request.env["HTTP_HOST"]) 

        format.html {render 'reset_password_sent' }
        format.js { render 'reset_password_sent' }
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
        respond_to do |format|
          @member.password = params[:password]
          if params[:password] != params[:password_repeat] || !@member.save
            @member.errors.add(:base, 'The password you entered twice did not match.')
            flash[:reset_pwd_errors] = @member.errors
            format.html { 
              if params[:return_page] == 'edit_profile'
                flash[:reset_pwd_params] = params
                redirect_to edit_profile_form_path(@member.ape_code)
              else
                redirect_to :action => 'password_reset_form'
              end
            }
            format.js { }
          else
            format.html { 
              if params[:return_page] == 'edit_profile'
                redirect_to edit_profile_form_path(@member.ape_code)
              else
                redirect_to home_path 
            end
            }
            format.js { }  
          end
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

