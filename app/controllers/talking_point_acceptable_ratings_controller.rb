class TalkingPointAcceptableRatingsController < ApplicationController
  # GET /talking_point_acceptable_ratings
  # GET /talking_point_acceptable_ratings.xml
  def index
    @talking_point_acceptable_ratings = TalkingPointAcceptableRating.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @talking_point_acceptable_ratings }
    end
  end

  # GET /talking_point_acceptable_ratings/1
  # GET /talking_point_acceptable_ratings/1.xml
  def show
    @talking_point_acceptable_rating = TalkingPointAcceptableRating.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @talking_point_acceptable_rating }
    end
  end

  # GET /talking_point_acceptable_ratings/new
  # GET /talking_point_acceptable_ratings/new.xml
  def new
    @talking_point_acceptable_rating = TalkingPointAcceptableRating.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @talking_point_acceptable_rating }
    end
  end

  # GET /talking_point_acceptable_ratings/1/edit
  def edit
    @talking_point_acceptable_rating = TalkingPointAcceptableRating.find(params[:id])
  end

  # POST /talking_point_acceptable_ratings
  # POST /talking_point_acceptable_ratings.xml
  def create
    @talking_point_acceptable_rating = TalkingPointAcceptableRating.new(params[:talking_point_acceptable_rating])

    respond_to do |format|
      if @talking_point_acceptable_rating.save
        format.html { redirect_to(@talking_point_acceptable_rating, :notice => 'Talking point acceptable rating was successfully created.') }
        format.xml  { render :xml => @talking_point_acceptable_rating, :status => :created, :location => @talking_point_acceptable_rating }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @talking_point_acceptable_rating.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /talking_point_acceptable_ratings/1
  # PUT /talking_point_acceptable_ratings/1.xml
  def update
    @talking_point_acceptable_rating = TalkingPointAcceptableRating.find(params[:id])

    respond_to do |format|
      if @talking_point_acceptable_rating.update_attributes(params[:talking_point_acceptable_rating])
        format.html { redirect_to(@talking_point_acceptable_rating, :notice => 'Talking point acceptable rating was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @talking_point_acceptable_rating.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /talking_point_acceptable_ratings/1
  # DELETE /talking_point_acceptable_ratings/1.xml
  def destroy
    @talking_point_acceptable_rating = TalkingPointAcceptableRating.find(params[:id])
    @talking_point_acceptable_rating.destroy

    respond_to do |format|
      format.html { redirect_to(talking_point_acceptable_ratings_url) }
      format.xml  { head :ok }
    end
  end
  
  def rate_talking_point
    logger.debug "rate_talking_point #{params[:talking_point_id]} with the rating #{params[:rating]}"

    talking_point = TalkingPointAcceptableRating.record( @member, params[:talking_point_id], params[:rating] )

    respond_to do |format|
      format.js { render 'rating_update', :locals=>{:talking_point => talking_point} }
    end
  end
  
end
