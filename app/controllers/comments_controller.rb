class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.xml
  def index
    
    if !params[:talking_point_id].nil?
      logger.debug "GET comments for talking point id: #{params[:talking_point_id]}"
      talking_point = TalkingPoint.find(params[:talking_point_id])
      @comments = talking_point.comments
      @commenting_members = Member.select('id, first_name, last_name, ape_code, photo_file_name').where( :id => @comments.map{|c| c.member_id}.uniq!)
      
      if !request.xhr?
        @team = talking_point.question.team
      end

      respond_to do |format|
        format.html { render :talking_point_comments, :layout => false} unless !request.xhr?
        format.html { render :talking_point_comments, :layout => 'plan'}
        format.xml  { render :xml => @comments }
      end
    elsif !params[:question_id].nil?
        logger.debug "GET comments for question id: #{params[:question_id]}"
        question = Question.find(params[:question_id])
        @comments = question.comments
        @commenting_members = Member.select('id, first_name, last_name, ape_code, photo_file_name').where( :id => @comments.map{|c| c.member_id}.uniq!)

        if !request.xhr?
          @team = question.team
        end

        respond_to do |format|
          format.html { render :question_comments, :layout => false} unless !request.xhr?
          format.html { render :question_comments, :layout => 'plan'}
          format.xml  { render :xml => @comments }
        end
      
    else
      @comments = Comment.all
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @comments }
      end
    end
    
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(@comment) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
