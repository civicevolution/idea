class IdeaRatingsController < ApplicationController
  # GET /idea_ratings
  # GET /idea_ratings.json
  def index
    @idea_ratings = IdeaRating.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @idea_ratings }
    end
  end

  # GET /idea_ratings/1
  # GET /idea_ratings/1.json
  def show
    @idea_rating = IdeaRating.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @idea_rating }
    end
  end

  # GET /idea_ratings/new
  # GET /idea_ratings/new.json
  def new
    @idea_rating = IdeaRating.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @idea_rating }
    end
  end

  # GET /idea_ratings/1/edit
  def edit
    @idea_rating = IdeaRating.find(params[:id])
  end

  # POST /idea_ratings
  # POST /idea_ratings.json
  def create
    @idea_rating = IdeaRating.new(params[:idea_rating])

    respond_to do |format|
      if @idea_rating.save
        format.html { redirect_to @idea_rating, notice: 'Idea rating was successfully created.' }
        format.json { render json: @idea_rating, status: :created, location: @idea_rating }
      else
        format.html { render action: "new" }
        format.json { render json: @idea_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /idea_ratings/1
  # PUT /idea_ratings/1.json
  def update
    @idea_rating = IdeaRating.find(params[:id])

    respond_to do |format|
      if @idea_rating.update_attributes(params[:idea_rating])
        format.html { redirect_to @idea_rating, notice: 'Idea rating was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @idea_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /idea_ratings/1
  # DELETE /idea_ratings/1.json
  def destroy
    @idea_rating = IdeaRating.find(params[:id])
    @idea_rating.destroy

    respond_to do |format|
      format.html { redirect_to idea_ratings_url }
      format.json { head :no_content }
    end
  end
end
