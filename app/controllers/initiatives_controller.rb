class InitiativesController < ApplicationController

  def join
    # add member to the initiative
    # is it allowed
    im = InitiativeMembers.new :initiative_id =>params[:_initiative_id], :member_id=>@member.id, :accept_tos=> params[:accept_tos], :email_opt_in => params[:email_opt_in] ? true : false, :member_category=> params[:member_category]
    allowed,message = InitiativeRestriction.allow_actionX(params[:_initiative_id], 'join_initiative', @member)
    im.errors.add(:base, message ) unless allowed
    if allowed
      # process the participant activities that I logged before they signed in 
      ppas = PreliminaryParticipantActivity.select('id, flash_params').where(:email => @member.email, :init_id => params[:_initiative_id] ).order(:id)
      ppas.each do |ppa|
      	case
      		when ppa.flash_params[:action].match(/rate_talking_point/)
      			TalkingPointAcceptableRating.record( @member, ppa.flash_params[:talking_point_id], ppa.flash_params[:rating] )
      		when ppa.flash_params[:action].match(/prefer_talking_point/)
      			tpp = TalkingPointPreference.find_or_create_by_member_id_and_talking_point_id(@member.id, ppa.flash_params[:talking_point_id])
      		when ppa.flash_params[:action].match(/create_talking_point_comment/)
      			comment = Comment.create(:member=> @member, :text => ppa.flash_params[:text], :parent_type => 13, :parent_id => ppa.flash_params[:talking_point_id] )
      		when ppa.flash_params[:action].match(/create_comment_comment/)
      			comment = Comment.create(:member=> @member, :text => ppa.flash_params[:text], :parent_type => 3,  :parent_id => ppa.flash_params[:comment_id] )
      		when ppa.flash_params[:action].match(/what_do_you_think/) && ppa.flash_params[:input_type] == "comment" 
      			comment = Comment.create(:member=> @member, :text => ppa.flash_params[:text], :parent_type => 1, :parent_id => ppa.flash_params[:question_id] )
      		when ppa.flash_params[:action].match(/what_do_you_think/) && ppa.flash_params[:input_type] == "talking_point" 
      			talking_point = TalkingPoint.create(:member=> @member, :text => ppa.flash_params[:text], :question_id => ppa.flash_params[:question_id] )
      		when ppa.flash_params[:action].match(/add_endorsement/)
      		  logger.debug 'process the endorsement'
      		  endorsement = Endorsement.find_or_create_by_member_id_and_team_id(@member.id,ppa.flash_params[:team_id])
            endorsement.text = ppa.flash_params[:text]
            endorsement.save
      		when ppa.flash_params[:action].match(/update_worksheet_ratings/)
      		  logger.debug "process the update_worksheet_ratings"
      		  unrecorded_talking_point_preferences = Question.update_worksheet_ratings( @member, ppa.flash_params )
      		  
      	end
      	#ppa.destroy
      end
      
    end
    respond_to do |format|
      if allowed && im.save
        format.html { redirect_to edit_profile_form_path(@member.ape_code) }
      else
        format.html { 
          flash[:join_init_errors] = im.errors
          flash[:join_in_params] = params
          redirect_to edit_profile_form_path(@member.ape_code) 
        }
      end
    end
    
  end

  # GET /initiatives
  # GET /initiatives.xml
  def index
    @initiatives = Initiative.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @initiatives }
    end
  end

  # GET /initiatives/1
  # GET /initiatives/1.xml
  def show
    @initiative = Initiative.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @initiative }
    end
  end

  # GET /initiatives/new
  # GET /initiatives/new.xml
  def new
    @initiative = Initiative.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @initiative }
    end
  end

  # GET /initiatives/1/edit
  def edit
    @initiative = Initiative.find(params[:id])
  end

  # POST /initiatives
  # POST /initiatives.xml
  def create
    @initiative = Initiative.new(params[:initiative])

    respond_to do |format|
      if @initiative.save
        flash[:notice] = 'Initiative was successfully created.'
        format.html { redirect_to(@initiative) }
        format.xml  { render :xml => @initiative, :status => :created, :location => @initiative }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @initiative.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /initiatives/1
  # PUT /initiatives/1.xml
  def update
    @initiative = Initiative.find(params[:id])

    respond_to do |format|
      if @initiative.update_attributes(params[:initiative])
        flash[:notice] = 'Initiative was successfully updated.'
        format.html { redirect_to(@initiative) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @initiative.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /initiatives/1
  # DELETE /initiatives/1.xml
  def destroy
    @initiative = Initiative.find(params[:id])
    @initiative.destroy

    respond_to do |format|
      format.html { redirect_to(initiatives_url) }
      format.xml  { head :ok }
    end
  end
end
