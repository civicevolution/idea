class TalkingPointVersionsController < ApplicationController
  
  def history
    talking_point = TalkingPoint.find(params[:talking_point_id])
    logger.debug "versions.size: #{talking_point.versions.size}"
    #debugger
    respond_to do |format|
      format.html { render 'history', :locals => {:talking_point => talking_point}, :layout => 'plan' }
      format.js { render 'history', :locals => {:talking_point => talking_point} }
    end
    
  end
  
  
  # GET /talking_point_versions
  # GET /talking_point_versions.xml
  def index
    @talking_point_versions = TalkingPointVersion.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @talking_point_versions }
    end
  end

  # GET /talking_point_versions/1
  # GET /talking_point_versions/1.xml
  def show
    @talking_point_version = TalkingPointVersion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @talking_point_version }
    end
  end

  # GET /talking_point_versions/new
  # GET /talking_point_versions/new.xml
  def new
    @talking_point_version = TalkingPointVersion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @talking_point_version }
    end
  end

  # GET /talking_point_versions/1/edit
  def edit
    @talking_point_version = TalkingPointVersion.find(params[:id])
  end

  # POST /talking_point_versions
  # POST /talking_point_versions.xml
  def create
    @talking_point_version = TalkingPointVersion.new(params[:talking_point_version])

    respond_to do |format|
      if @talking_point_version.save
        format.html { redirect_to(@talking_point_version, :notice => 'Talking point version was successfully created.') }
        format.xml  { render :xml => @talking_point_version, :status => :created, :location => @talking_point_version }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @talking_point_version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /talking_point_versions/1
  # PUT /talking_point_versions/1.xml
  def update
    @talking_point_version = TalkingPointVersion.find(params[:id])

    respond_to do |format|
      if @talking_point_version.update_attributes(params[:talking_point_version])
        format.html { redirect_to(@talking_point_version, :notice => 'Talking point version was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @talking_point_version.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /talking_point_versions/1
  # DELETE /talking_point_versions/1.xml
  def destroy
    @talking_point_version = TalkingPointVersion.find(params[:id])
    @talking_point_version.destroy

    respond_to do |format|
      format.html { redirect_to(talking_point_versions_url) }
      format.xml  { head :ok }
    end
  end
end
