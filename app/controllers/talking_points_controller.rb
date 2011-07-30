class TalkingPointsController < ApplicationController
  # GET /talking_points
  # GET /talking_points.xml
  def index
    
    if !params[:question_id].nil?
      logger.debug "GET talking points for question id: #{params[:question_id]}"

      @question = Question.find(params[:question_id])
      last_visit_ts = Time.local(2012,2,23) 
      
      talking_points_to_display = @question.remaining_talking_points(params[:talking_point_ids])
      TalkingPoint.get_and_assign_stats( @question, talking_points_to_display, @member )
      
      if !request.xhr?
        @team = @question.team
      end

      respond_to do |format|
        format.html { render :question_talking_points, :layout => false} unless !request.xhr?
        format.html { render :question_talking_points, :layout => 'plan'}
        format.xml  { render :xml => @talking_points }
      end
    else
      @talking_points = TalkingPoint.all
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @talking_points }
      end
    end
  end

  # GET /talking_points/1
  # GET /talking_points/1.xml
  def show
    @talking_point = TalkingPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @talking_point }
    end
  end

  # GET /talking_points/new
  # GET /talking_points/new.xml
  def new
    @talking_point = TalkingPoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @talking_point }
    end
  end

  # GET /talking_points/1/edit
  def edit
    @talking_point = TalkingPoint.find(params[:id])
  end

  # POST /talking_points
  # POST /talking_points.xml
  def create
    logger.debug "TalkingPoint.create"
  	@talking_point = Question.find(params[:question_id]).talking_points.create(:member=> @member, :text => params[:text])
    #@talking_point = TalkingPoint.new(params[:talking_point])

    respond_to do |format|
      if @talking_point.save
        format.html { render :partial=> 'plan/talking_point', :locals=>{:talking_point=>@talking_point} } if request.xhr?
        format.html { redirect_to(@talking_point, :notice => 'Talking point was successfully created.') }
        format.xml  { render :xml => @talking_point, :status => :created, :location => @talking_point }
      else
        format.html { render :text => 'talking_point save failed' } if request.xhr?
        format.html { render :action => "new" }
        format.xml  { render :xml => @talking_point.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  def create_question_talking_point
    logger.debug "TalkingPoint.create_question_talking_point"
    @talking_point = Question.find(params[:question_id]).talking_points.create(:member=> @member, :text => params[:text])

    respond_to do |format|
      if @talking_point.save
        format.js { render 'talking_point_for_question', :locals=>{:talking_point=>@talking_point, :question_id => @talking_point.question_id} }
        format.html { render :partial=> 'plan/talking_point', :locals=>{:comment=>@talking_point} } if request.xhr?
        format.html { redirect_to(@talking_point, :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @talking_point, :status => :created, :location => @comment }
      else
        format.js { render 'talking_point_for_question_errors', :locals=>{:talking_point=>@talking_point} }
        format.html { render :text => 'talking_point save failed' } if request.xhr?
        format.html { render :action => "new" }
        format.xml  { render :xml => @talking_point.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
  

  # PUT /talking_points/1
  # PUT /talking_points/1.xml
  def update
    @talking_point = TalkingPoint.find(params[:id])

    respond_to do |format|
      if @talking_point.update_attributes(params[:talking_point])
        format.html { redirect_to(@talking_point, :notice => 'Talking point was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @talking_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /talking_points/1
  # DELETE /talking_points/1.xml
  def destroy
    @talking_point = TalkingPoint.find(params[:id])
    @talking_point.destroy

    respond_to do |format|
      format.html { redirect_to(talking_points_url) }
      format.xml  { head :ok }
    end
  end
end
