class MembersController < ApplicationController
  skip_before_filter :authorize, :only => [:new_profile_form, :new_profile_post, :display_profile]
  layout "plan", :only => [:new_profile_form, :edit_profile_form, :display_profile]
  
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
      
      # Should I put this in the section where they join the initiative?
      # process the participant activities that I logged before they signed in 
      ppas = PreliminaryParticipantActivity.select('id, flash_params').where(:email => member.email).order(:id)
      ppas.each do |ppa|
      	case
      		when ppa.flash_params[:action].match(/rate_talking_point/)
      			TalkingPointAcceptableRating.record( member, ppa.flash_params[:talking_point_id], ppa.flash_params[:rating] )
      		when ppa.flash_params[:action].match(/prefer_talking_point/)
      			tpp = TalkingPointPreference.find_or_create_by_member_id_and_talking_point_id(member.id, ppa.flash_params[:talking_point_id])
      		when ppa.flash_params[:action].match(/create_talking_point_comment/)
      			comment = Comment.create(:member=> member, :text => ppa.flash_params[:text], :parent_type => 13, :parent_id => ppa.flash_params[:talking_point_id] )
      		when ppa.flash_params[:action].match(/create_comment_comment/)
      			comment = Comment.create(:member=> member, :text => ppa.flash_params[:text], :parent_type => 3, :parent_id => ppa.flash_params[:comment_id] )
      		when ppa.flash_params[:action].match(/what_do_you_think/) && ppa.flash_params[:input_type] == "comment" 
      			comment = Comment.create(:member=> member, :text => ppa.flash_params[:text], :parent_type => 1, :parent_id => ppa.flash_params[:question_id] )
      		when ppa.flash_params[:action].match(/what_do_you_think/) && ppa.flash_params[:input_type] == "talking_point" 
      			talking_point = TalkingPoint.create(:member=> member, :text => ppa.flash_params[:text], :question_id => ppa.flash_params[:question_id] )
      	end
      	ppa.destroy
      end      
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
