class IdeaVersionsController < ApplicationController
  # GET /idea_versions
  # GET /idea_versions.json
  def index
    @idea_versions = IdeaVersion.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @idea_versions }
    end
  end

  # GET /idea_versions/1
  # GET /idea_versions/1.json
  def show
    @idea_version = IdeaVersion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @idea_version }
    end
  end

  # GET /idea_versions/new
  # GET /idea_versions/new.json
  def new
    @idea_version = IdeaVersion.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @idea_version }
    end
  end

  # GET /idea_versions/1/edit
  def edit
    @idea_version = IdeaVersion.find(params[:id])
  end

  # POST /idea_versions
  # POST /idea_versions.json
  def create
    @idea_version = IdeaVersion.new(params[:idea_version])

    respond_to do |format|
      if @idea_version.save
        format.html { redirect_to @idea_version, notice: 'Idea version was successfully created.' }
        format.json { render json: @idea_version, status: :created, location: @idea_version }
      else
        format.html { render action: "new" }
        format.json { render json: @idea_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /idea_versions/1
  # PUT /idea_versions/1.json
  def update
    @idea_version = IdeaVersion.find(params[:id])

    respond_to do |format|
      if @idea_version.update_attributes(params[:idea_version])
        format.html { redirect_to @idea_version, notice: 'Idea version was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @idea_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /idea_versions/1
  # DELETE /idea_versions/1.json
  def destroy
    @idea_version = IdeaVersion.find(params[:id])
    @idea_version.destroy

    respond_to do |format|
      format.html { redirect_to idea_versions_url }
      format.json { head :no_content }
    end
  end
end
