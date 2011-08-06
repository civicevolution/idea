class CommentsController < ApplicationController
  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end
  
  def talking_point_comments
    logger.debug "GET comments for talking point id: #{params[:talking_point_id]} (talking_point_comments)"
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
  end    
  
  def question_comments
    logger.debug "GET comments for question id: #{params[:question_id]} (question_comments)"
    question = Question.find(params[:question_id])
    #@comments = question.comments
    @comments = question.remaining_comments(params[:comment_ids])
    @resources = []
    
    @commenting_members = Member.select('id, first_name, last_name, ape_code, photo_file_name').where( :id => @comments.map{|c| c.member_id}.uniq!)

    if !request.xhr?
      @team = question.team
    end

    respond_to do |format|
      format.html { render :question_comments, :layout => false} unless !request.xhr?
      format.html { render :question_comments, :layout => 'plan'}
      format.xml  { render :xml => @comments }
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

  def reply
    
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    
    respond_to do |format|
      if @comment.save
        format.html { redirect_to(@comment, :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def create_talking_point_comment
    debugger
    logger.debug "Comment.create_talking_point_comment"
    #@comment = TalkingPoint.find(params[:talking_point_id]).comments.create(:member=> @member, :text => params[:text], :parent_type => params[:parent_type], :parent_id => params[:parent_id])

    @comment = Comment.find(1034)
    
    respond_to do |format|
      if @comment#.save
        format.js { render 'comment_for_talking_point', :locals=>{:comment=>@comment, :members => [@member], :question_id => @comment.talking_point.question_id} }
        format.html { render :partial=> 'plan/comment', :locals=>{:comment=>@comment, :members => [@member]} } if request.xhr?
        format.html { redirect_to(@comment, :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.html { render :text => 'comment save failed' } if request.xhr?
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def create_question_comment
    logger.debug "Comment.create_question_comment"
    @comment = Question.find(params[:question_id]).comments.create(:member=> @member, :text => params[:text], :parent_type => 1, :parent_id => params[:question_id])

    respond_to do |format|
      if @comment.save
        format.js { render 'comment_for_question', :locals=>{:comment=>@comment, :members => [@member], :question_id => @comment.parent_id} }
        format.html { render :partial=> 'plan/comment', :locals=>{:comment=>@comment, :members => [@member]} } if request.xhr?
        format.html { redirect_to(@comment, :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.js { render 'comment_for_question_errors', :locals=>{:comment=>@comment} }
        format.html { render :text => 'comment save failed' } if request.xhr?
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
  
  protected
  
  COMMENTS_CONTROLLER_PUBLIC_METHODS = ['talking_point_comments', 'question_comments']
  
  def authorize
    #debugger
    unless COMMENTS_CONTROLLER_PUBLIC_METHODS.include? request[:action]
      # do this except for public methods
      if (@member.nil? || @member.id == 0 )
        if request.xhr?
          respond_to do |format|
            case request[:action]
              when 'create_answer'
                act = 'add or edit an answer'
              when 'create_comment'
                act = 'add or edit a comment'
              when 'create_brainstorm_idea'
                act = 'add a brainstorming idea'
              else
                act = 'continue'
            end
            format.json { render :text => [ {'Sign in required'=> [act]} ].to_json, :status => 409 }
          end
          return
        else
          flash[:pre_authorize_uri] = request.request_uri
          flash[:notice] = "Please sign in"
          render :template => 'welcome/must_sign_in', :layout => 'welcome'
          
        end
      end
    end
    if @member.nil? 
      @member = Member.new :first_name=>'Unknown', :last_name=>'Visitor'
      @member.id = 0
      @member.email = ''
      @member.last_visit_ts = Time.local(2012,2,23)
    end
  end
  
end
