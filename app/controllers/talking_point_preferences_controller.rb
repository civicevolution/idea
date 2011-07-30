class TalkingPointPreferencesController < ApplicationController
  # GET /talking_point_preferences
  # GET /talking_point_preferences.xml
  def index
    @talking_point_preferences = TalkingPointPreference.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @talking_point_preferences }
    end
  end

  # GET /talking_point_preferences/1
  # GET /talking_point_preferences/1.xml
  def show
    @talking_point_preference = TalkingPointPreference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @talking_point_preference }
    end
  end

  # GET /talking_point_preferences/new
  # GET /talking_point_preferences/new.xml
  def new
    @talking_point_preference = TalkingPointPreference.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @talking_point_preference }
    end
  end

  # GET /talking_point_preferences/1/edit
  def edit
    @talking_point_preference = TalkingPointPreference.find(params[:id])
  end

  # POST /talking_point_preferences
  # POST /talking_point_preferences.xml
  def create
    @talking_point_preference = TalkingPointPreference.new(params[:talking_point_preference])

    respond_to do |format|
      if @talking_point_preference.save
        format.html { redirect_to(@talking_point_preference, :notice => 'Talking point preference was successfully created.') }
        format.xml  { render :xml => @talking_point_preference, :status => :created, :location => @talking_point_preference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @talking_point_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /talking_point_preferences/1
  # PUT /talking_point_preferences/1.xml
  def update
    @talking_point_preference = TalkingPointPreference.find(params[:id])

    respond_to do |format|
      if @talking_point_preference.update_attributes(params[:talking_point_preference])
        format.html { redirect_to(@talking_point_preference, :notice => 'Talking point preference was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @talking_point_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /talking_point_preferences/1
  # DELETE /talking_point_preferences/1.xml
  def destroy
    @talking_point_preference = TalkingPointPreference.find(params[:id])
    @talking_point_preference.destroy

    respond_to do |format|
      format.html { redirect_to(talking_point_preferences_url) }
      format.xml  { head :ok }
    end
  end
  
  def prefer_talking_point
    logger.debug "prefer_talking_point #{params[:talking_point_id]} with the prefer #{params[:prefer]}"

    if( params[:prefer] == 'true' )
      @preference = TalkingPointPreference.create( :member_id=> @member.id, :talking_point_id=>params[:talking_point_id])
    else
      TalkingPointPreference.find_by_member_id_and_talking_point_id(@member.id, params[:talking_point_id]).destroy
    end
        
    respond_to do |format|
      format.js { render 'preference_update', :locals=>{:member => @member} }
    end
  end
  
  
end
