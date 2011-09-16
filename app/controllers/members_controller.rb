class MembersController < ApplicationController
  skip_before_filter :authorize, :only => [:new_profile_form, :new_profile_post, :display_profile, :invite_friends_form]
  layout "plan", :only => [:new_profile_form, :edit_profile_form, :display_profile, :invite_friends_form, :invite_friends_post]
  
  def new_profile_form
    flash[:profile_params].each_pair{|key,val| params[key] = val } unless flash[:profile_params].nil?
    # use the code to look up the user's email address
    if params[:code].nil?
      render 'new_profile_code_not_found'
    else
      email = EmailLookupCode.get_email( params[:code] )
      @email = email unless email.nil?
      session[:code] = params[:code] unless params[:code].nil?
      render 'new_profile_form'
    end
  end

  
  def new_profile_post
    # check the captcha before saving
    member = Member.new :email => EmailLookupCode.get_email( session[:code] ) , :first_name => params[:first_name] , :last_name  => params[:last_name] , :pic_id=> 0, :init_id => 0 , :confirmed => true
    if verify_recaptcha( :model => member, :message => "We're sorry, but the captcha didn't match. Please try again." ) && member.save
      logger.debug "The member has been saved, process their past activities"
      session[:member_id] = member.id
      session[:code] = nil
      redirect_to edit_profile_form_path(member.ape_code)
    else
      logger.debug "Redisplay new profile form with a new captcha"
      flash[:profile_params] = params
      flash[:member_errors] = member.errors
      redirect_to new_profile_form_path
    end
  end
  
  def edit_profile_form

  end
  
  def edit_profile_post
    debugger
  end
  
  def display_profile
    
  end
  
  def upload_member_photo
    logger.debug "save_photo member_id: #{@member.id}"
    
    @member.photo = params[:photo]
    @member.save
    
    respond_to do |format|
      format.html { redirect_to edit_profile_form_path(@member.ape_code) }
    end
  end 
  
  def invite_friends_form
    team = Team.find(params[:team_id])
    
    
    respond_to do |format|
      format.html { render 'invite_friends_form', :locals => { :team => team } }
    end
    
    
  end
  
  def invite_friends_post
    
    team = nil
    
    respond_to do |format|
      format.html { render 'invite_friends_sent', :locals => { :team => team } }
    end
    return
    
    logger.debug "invite_friends #{params.inspect}"
    
    member = Member.find(session[:member_id])
    team = Team.find(params[:team_id])
    
    @invite = InviteEmail.new :sender => member, :recipient_emails => params[:recipient_emails], :message=> params[:message]
    @invite.valid?

    if @invite.errors.empty? && params[:send_now] == 'true'
      # invite is valid and to be sent now - check the captcha before sending
      # I shortened the field name in form b/c it was removed by recaptcha
      params[:recaptcha_challenge_field] = params[:recaptcha_challenge]
      params[:recaptcha_response_field] =  params[:recaptcha_response]
      validate_recap(params, @invite.errors)
    end
    
    respond_to do |format|
      if @invite.errors.empty?
        if params[:send_now] != 'true'
          recipient =  @invite.recipients[0]
          logger.debug "Generate a sample email to #{recipient[:first_name]} at #{recipient[:email]}"
          @email = ProposalMailer.team_send_invite(member, recipient, @invite, team, request.env["HTTP_HOST"] )
          format.html { render :action => "team/preview_invite_request", :layout => false } if request.xhr?
          format.html { render :action => "team/preview_invite_request", :layout => 'welcome' }
        else
          @invite.recipients.each do |recipient|
            logger.debug "Send an email to #{recipient[:first_name]} at #{recipient[:email]}"
            ProposalMailer.delay.team_send_invite(member, recipient, @invite, team, request.env["HTTP_HOST"] )
          end
          format.html { render :action => "team/acknowledge_invite_request", :layout => false } if request.xhr?
          format.html { render :action => "team/acknowledge_invite_request", :layout => 'welcome' }
          
        end
      else
        if !@invite.errors[:recipient_emails].nil? && @invite.errors[:recipient_emails].size() > 0 && request.xhr?
          format.html { render :action => "team/invite_request_email_errors", :layout => false }
        else
          format.json { render :text => [@invite.errors].to_json, :status => 409 }    
        end
      end
    end
    
  end
  
  
  
  
  
  # GET /members
  # GET /members.xml
  def index
    @members = Member.find(:all, :order => :first_name )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @members }
    end
  end

  # GET /members/1
  # GET /members/1.xml
  def show
    @member = Member.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/new
  # GET /members/new.xml
  def new
    @member = Member.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/1/edit
  def edit
    @member = Member.find(params[:id])
  end

  # POST /members
  # POST /members.xml
  def create
    @member = Member.new(params[:member])

    respond_to do |format|
      if @member.save
        flash[:notice] = "Member #{@member.first_name} #{@member.last_name} was successfully created."
        format.html { redirect_to(:action=>'index') }
        format.xml  { render :xml => @member, :status => :created, :location => @member }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.xml
  def update
    @member = Member.find(params[:id])

    respond_to do |format|
      if @member.update_attributes(params[:member])
        flash[:notice] = "Member  #{@member.first_name} #{@member.last_name} was successfully updated."
        format.html { redirect_to(:action=>'index') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.xml
  def destroy
    @member = Member.find(params[:id])
    @member.destroy

    respond_to do |format|
      format.html { redirect_to(members_url) }
      format.xml  { head :ok }
    end
  end
end
