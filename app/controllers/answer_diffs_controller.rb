class AnswerDiffsController < ApplicationController
  # GET /answer_diffs
  # GET /answer_diffs.xml
  def index
    @answer_diffs = AnswerDiff.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @answer_diffs }
    end
  end

  # GET /answer_diffs/1
  # GET /answer_diffs/1.xml
  def show
    @answer_diff = AnswerDiff.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @answer_diff }
    end
  end

  # GET /answer_diffs/new
  # GET /answer_diffs/new.xml
  def new
    @answer_diff = AnswerDiff.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @answer_diff }
    end
  end

  # GET /answer_diffs/1/edit
  def edit
    @answer_diff = AnswerDiff.find(params[:id])
  end

  # POST /answer_diffs
  # POST /answer_diffs.xml
  def create
    @answer_diff = AnswerDiff.new(params[:answer_diff])

    respond_to do |format|
      if @answer_diff.save
        format.html { redirect_to(@answer_diff, :notice => 'Answer diff was successfully created.') }
        format.xml  { render :xml => @answer_diff, :status => :created, :location => @answer_diff }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @answer_diff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /answer_diffs/1
  # PUT /answer_diffs/1.xml
  def update
    @answer_diff = AnswerDiff.find(params[:id])

    respond_to do |format|
      if @answer_diff.update_attributes(params[:answer_diff])
        format.html { redirect_to(@answer_diff, :notice => 'Answer diff was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @answer_diff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /answer_diffs/1
  # DELETE /answer_diffs/1.xml
  def destroy
    @answer_diff = AnswerDiff.find(params[:id])
    @answer_diff.destroy

    respond_to do |format|
      format.html { redirect_to(answer_diffs_url) }
      format.xml  { head :ok }
    end
  end
end
