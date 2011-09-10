class MembersController < ApplicationController
  skip_before_filter :authorize, :only => [:new_profile_form, :new_profile_post, :display_profile]
  layout "plan", :only => [:new_profile_form, :edit_profile_form, :display_profile]
  
  def new_profile_form
    flash[:profile_params].each_pair{|key,val| params[key] = val } unless flash[:profile_params].nil?
    # use the code to look up the user's email address
    email = EmailLookupCode.get_email( params[:code] ) unless params[:code].nil?
    session[:email] = email unless email.nil?
    session[:code] = params[:code] unless params[:code].nil?
  end
  
  def new_profile_post
    # check the captcha before saving
    member = Member.new :email => session[:email] , :first_name => params[:first_name] , :last_name  => params[:last_name] , :pic_id=> 0, :init_id => 0 , :confirmed => true
    if verify_recaptcha( :model => member, :message => "We're sorry, but the captcha didn't match. Please try again." ) && member.save
      logger.debug "The member has been saved, process their past activities"
      session[:member_id] = member.id
      session[:email] = nil
      # process the participant activities that I logged before they signed in 
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
