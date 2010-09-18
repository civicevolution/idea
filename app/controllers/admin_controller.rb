class AdminController < ApplicationController

  # just display the form and wait for user to
  # enter a name and password
  
  def login
    if request.post?
      member = Member.authenticate(params[:email], params[:password])
      if member
        session[:member_id] = member.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || { :action => "index" })
      else
        flash.now[:notice] = "Invalid email/password combination"
      end
    end
    #debugger
  end
  

  
  def logout
    session[:member_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:controller=>'welcome', :action => "index")
  end
  

  
  def index
    @total_members = Member.count
  end
  
end