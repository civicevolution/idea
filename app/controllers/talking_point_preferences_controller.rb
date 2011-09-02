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
    
    talking_point = TalkingPoint.find( params[:talking_point_id] )

    if( params[:prefer] == 'false' )
      tp = TalkingPointPreference.find_by_member_id_and_talking_point_id(@member.id, params[:talking_point_id])
      tp.destroy unless tp.nil?
      render_select = false
    else
      pref_count = TalkingPoint.joins(:talking_point_preferences).where('talking_point_preferences.member_id = ? AND question_id = ?', @member.id, talking_point.question_id).count()
      if pref_count < 5
        @preference = TalkingPointPreference.create( :member_id=> @member.id, :talking_point_id=>params[:talking_point_id])
        render_select = false
      else
        render_select = true
      end
    end
    respond_to do |format|
      if render_select
        talking_points = [talking_point] + TalkingPointPreference.preferred_talking_points( talking_point.question_id, @member.id )
        format.js { render 'preference_review_select', :locals=>{:talking_point => talking_point, :talking_points => talking_points, :question_id => talking_point.question_id } }
      else
        tpp = TalkingPointPreference.sums(talking_point.id)
        # Warning - this logger.debug statement is necessary so tpp.size > 0 will evaluate correctly
        logger.debug "tpp.inspect #{tpp.inspect}"
        talking_point.preference_votes = tpp.size > 0 ? tpp[0]['count'] : 0
        talking_point.my_preference = params[:prefer] == 'true' ? true : false
        format.js { render 'preference_update', :locals=>{:talking_point => talking_point } }  
      end
    end
  end
  
  def update_preferences
    #2011-08-31 15:30:20 [INFO ] Parameters: {"question_id"=>"350", "ids"=>["31", "8", "29", "28", "2"]} (pid:278)
    
    params[:ids] ||= []
    
    question = TalkingPointPreference.update_question_preferred_talking_points( params[:question_id], params[:ids], @member )

    respond_to do |format|
      format.js { render 'update_reviewed_preferences', :locals=>{:question => question } }
    end
  end

  
end
