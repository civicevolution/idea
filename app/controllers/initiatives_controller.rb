class InitiativesController < ApplicationController

  def join
    # add member to the initiative
    # is it allowed
    im = InitiativeMembers.new :initiative_id =>params[:_initiative_id], :member_id=>@member.id, :accept_tos=> params[:accept_tos], :email_opt_in => params[:email_opt_in] ? true : false, :member_category=> params[:member_category]
    allowed,message = InitiativeRestriction.allow_actionX(params[:_initiative_id], 'join_initiative', @member)
    im.errors.add(:base, message ) unless allowed
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
