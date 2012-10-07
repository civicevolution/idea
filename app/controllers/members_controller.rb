class MembersController < ApplicationController
  skip_before_filter :authorize, :only => [:new_profile_form, :new_profile_post, :display_profile, :invite_friends_form, :request_new_access_code, :send_new_access_code]
  layout "plan", :only => [:new_profile_form, :edit_profile_form, :display_profile, :invite_friends_form, :invite_friends_post, :request_new_access_code, :send_new_access_code]
  
  def new_profile_form
    flash[:profile_params].each_pair{|key,val| params[key] = val } unless flash[:profile_params].nil?
    # use the code to look up the user's email address
    params[:code] ||= session[:code]
    if params[:code].nil? 
      render 'new_profile_code_not_found'
    else
      email = EmailLookupCode.get_email( params[:code] )
      @email = email unless email.nil?
      session[:code] = params[:code] unless params[:code].nil?
      render 'new_profile_form', layout: 'home'
    end
  end

  
  def new_profile_post
    # check the captcha before saving
    member = Member.new :email => EmailLookupCode.get_email( session[:code] ) , :first_name => params[:first_name] , :last_name  => params[:last_name] , :pic_id=> 0, :confirmed => true
    member.init_id = params[:_initiative_id]
    member.ip = request.remote_ip
    member.location = 'Australia/Perth'
    member.domain = Rails.root.to_s.match(/^\/data\//) ? Rails.root.to_s.match(/\/data\/(\w+)\//)[1] : Rails.root.to_s.match(/\/ce_development\/Rails\/(\w+)/)[1]
    if verify_recaptcha( :model => member, :message => "We're sorry, but the text you entered in the spam test didn't match. Please try again." ) && member.save
      logger.debug "The member has been saved, process their past activities"
      session[:member_id] = member.id
      session[:code] = nil
      MemberMailer.delay.report_confirmation(member, params[:_app_name])
      ActiveSupport::Notifications.instrument( 'tracking', :event => 'Create new profile', :params => params.merge(:member_id => member.id))
      redirect_to edit_profile_form_path(member.ape_code)
    else
      logger.debug "Redisplay new profile form with a new captcha"
      flash[:profile_params] = params
      flash[:member_errors] = member.errors
      redirect_to new_profile_form_path()
    end
  end
  
  def edit_profile_form
    respond_to do |format|
      format.html { render 'edit_profile_form', layout: 'home' }
    end
  end
  
  def edit_profile_post
    debugger
  end
  
  def display_profile
    profile = Member.find_by_ape_code(params[:ape_code])
    respond_to do |format|
      format.html { render 'display_profile', :locals=>{:profile=>profile} }
      format.js{ render 'display_profile', :locals=>{:profile=>profile} }
    end
    
  end
  
  def upload_member_photo
    logger.debug "save_photo member_id: #{@member.id}"
    
    @member.photo = params[:photo]
    if @member.save
      #ActiveSupport::Notifications.instrument( 'tracking', :event => 'Upload profile photo', :params => params.merge(:member_id => @member.id))
    end
    respond_to do |format|
      format.html { redirect_to edit_profile_form_path(@member.ape_code) }
    end
  end 
  
  def invite_friends_form
    team = Team.find_by_id(params[:team_id])
    if flash[:params]
      params[:message] = flash[:params][:message]
      params[:recipient_emails] = flash[:params][:recipient_emails]
    end
    #debugger
    @form_errors ||= flash[:form_errors]
    respond_to do |format|
      format.html { render 'invite_friends_form', :formats => [:html], :locals => { :team => team } }
      format.js { render 'invite_friends_form', :formats => [:js], :locals => { :team => team } }
    end
  end
  
  def invite_friends_preview
    team = Team.find_by_id( params[:team_id] || flash[:params][:team_id] )

    if flash[:params]
      params[:message] ||= flash[:params][:message]
      params[:recipient_emails] ||= flash[:params][:recipient_emails]
    end
    
    @invite = InviteEmail.new :sender => @member, 
      :recipient_emails => params[:recipient_emails], 
      :message=> params[:message]
    @invite.valid?
    @preview_errors ||= flash[:preview_errors]
    
    respond_to do |format|
      if @invite.errors.empty?
        recipient =  @invite.recipients[0]
        #logger.debug "Generate a sample email to #{recipient[:first_name]} at #{recipient[:email]}"
        @email = ProposalMailer.team_send_invite(@member, recipient, @invite.message, team, request.env["HTTP_HOST"], params[:_app_name] )
        if flash[:params]
          flash[:params][:recipient_emails] = params[:recipient_emails] || flash[:params][:recipient_emails]
          flash[:params][:message] = params[:message] || flash[:params][:message]
        else
          flash[:params] = params
        end
        flash.keep

        format.html { render :template => "members/preview_invite_request", :locals=>{:team=>team, :use_recaptcha_tags => true}, :layout => 'plan' }
        format.js { render :template => "members/preview_invite_request", :locals=>{:team=>team}}
      else
        if flash[:params]
          flash[:params][:recipient_emails] = params[:recipient_emails] || flash[:params][:recipient_emails]
          flash[:params][:message] = params[:message] || flash[:params][:message]
        else
          flash[:params] = params
        end
        flash.keep
        format.html { 
          flash[:form_errors] = @invite.errors
          redirect_to invite_friends_form_path(team.id) 
        }
        format.js { 
          @form_errors = @invite.errors
          invite_friends_form 
        }
      end
    end
  end

  def invite_friends_send

    team = Team.find_by_id( params[:team_id] || flash[:params][:team_id] )

    @invite = InviteEmail.new :sender => @member, 
      :recipient_emails => params[:recipient_emails] || flash[:params][:recipient_emails], 
      :message=> params[:message] || flash[:params][:message]
    if !@invite.valid?
      if flash[:params]
        flash[:params][:recipient_emails] = params[:recipient_emails] || flash[:params][:recipient_emails]
        flash[:params][:message] = params[:message] || flash[:params][:message]
      else
        flash[:params] = params
      end
      
      respond_to do |format|
        format.html { 
          flash[:form_errors] = @invite.errors
          redirect_to invite_friends_form_path(team.id) 
        }
        format.js { 
          @form_errors = @invite.errors
          invite_friends_form 
        }
      end
      return
    end

    verify_recaptcha( :model => @invite, :message => "We're sorry, but the text you entered in the spam test didn't match. Please try again." )
    
    team_id = team ? team.id : 0
    
    respond_to do |format|
      if @invite.errors.empty?
        @invite.recipients.each do |recipient|
          #logger.debug "Send an email to #{recipient[:first_name]} at #{recipient[:email]}"
          ProposalMailer.delay.team_send_invite(@member, recipient, @invite.message, team, request.env["HTTP_HOST"], params[:_app_name] )
          Invite.create :member_id => @member.id, :initiative_id => params[:_initiative_id], :team_id => team_id, :first_name => recipient[:first_name],:last_name => recipient[:last_name], :email => recipient[:email], :_ilc => nil
        end
        flash[:invite] = @invite
        flash[:team_id] = team_id
        format.html { redirect_to invite_friends_acknowledge_path }
        format.js { 
          render :template => "members/acknowledge_invite_request", :formats=>[:js], :locals=>{:team_id=>team_id, :invite=>@invite}
        } 
      else

        if flash[:params]
          flash[:params][:recipient_emails] = params[:recipient_emails] || flash[:params][:recipient_emails]
          flash[:params][:message] = params[:message] || flash[:params][:message]
        else
          flash[:params] = params
        end
        flash.keep
        format.html { 
          flash[:preview_errors] = @invite.errors
          redirect_to invite_friends_preview_path(team.id) 
        }
        format.js { 
          @preview_errors = @invite.errors
          invite_friends_preview 
        }
      end          
    end
  end

  def acknowledge_invite_request
    flash.keep
    respond_to do |format|
      format.html { render :template => "members/acknowledge_invite_request.html", :locals=>{:team_id=>flash[:team_id], :invite=>flash[:invite]}, :layout => 'plan' }
    end
  end
  
  def request_new_access_code
  end
  
  def send_new_access_code
    @member = Member.find_by_email(params[:email].downcase)
    if @member.nil?
      
      #render 'email_not_found', :layout => 'plan'
      flash[:error]= 'The email you entered was not found'
      flash[:email] = params[:email]
      redirect_to request_new_access_code_path
      request_new_access_code
      return
    else
      #debugger
      # create and store a code for the member
      mcode = MemberLookupCode.get_code(@member.id, {:scenario=>'send new access code'} )
      
      logger.debug "generate an email to #{@member.email} with code: #{mcode}"
      # generate an email to the member      
      # generate new url = original url with mlc replaced with mcode
      new_url = flash[:pre_request_access_code_uri].sub(/\b_mlc=.{36}/,'_mlc=' + mcode)
      MemberMailer.delay.new_access_code(@member, new_url, request.env["HTTP_HOST"]) 
      @email = @member.email
      @member = nil
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
