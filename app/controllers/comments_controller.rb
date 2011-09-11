class CommentsController < ApplicationController
  skip_before_filter :authorize, :only => [:talking_point_comments, :question_comments, :comment_comments, :comment_reply ]
  
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
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:talking_point_id=>params[:talking_point_id]}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    @team = Team.find(team_id)
    
    @talking_point = TalkingPoint.find(params[:talking_point_id])
    @comments = @talking_point.comments
    
    respond_to do |format|
      format.js { render :partial => 'talking_point_comments', :locals=> {:talking_point => @talking_point, :comments => @comments, :com_criteria => @team.com_criteria }, :layout => false}
      format.html { render :partial => 'talking_point_comments', :locals=> {:talking_point => @talking_point, :comments => @comments, :com_criteria => @team.com_criteria }, :layout => false} unless !request.xhr?
      format.html { render 'talking_point_comments', :locals=> {:talking_point => @talking_point, :comments => @comments, :com_criteria => @team.com_criteria }, :layout => 'plan'}
      format.xml  { render :xml => @comments }
    end
  end    
  
  def question_comments
    logger.debug "GET comments for question id: #{params[:question_id]} (question_comments)"
    
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id=>params[:question_id]}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    @team = Team.find(team_id)
    
    question = Question.find(params[:question_id])
    #@comments = question.comments
    @comments = question.remaining_comments(params[:comment_ids])
    @resources = []
    
    comment_coms = Comment.com_counts(@comments.map(&:id), @member.last_visit_ts)
    @comments.each do |c|
      ccom = comment_coms.detect{|cc| cc['comment_id'].to_i == c.id}
      c.coms = ccom['coms'].to_i
      c.new_coms = ccom['new_coms'].to_i
    end


    if !request.xhr?
      @team = question.team
    end

    respond_to do |format|
      format.html { render :question_comments, :layout => false} unless !request.xhr?
      format.html { render :question_comments, :layout => 'plan'}
      format.xml  { render :xml => @comments }
    end
    
  end

  def comment_comments
    logger.debug "GET comments for comment id: #{params[:comment_id]} (comment_comments)"

    # comment_comments only exist under the question comments, so use the com's parent_id as question_id
    @comment = Comment.find(params[:comment_id])
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id=>@comment.parent_id}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    @team = Team.find(team_id)
    
    @comments = @comment.comments

    respond_to do |format|
      format.js { render :partial => 'comment_comments', :locals=> {:comment => @comment, :comments => @comments, :com_criteria => @team.com_criteria }, :layout => false}
      #format.html { render :partial => 'comment_comments', :locals=> {:comment => @comment, :comments => @comments, :com_criteria => @team.com_criteria}, :layout => false} unless !request.xhr?
      format.html { render 'comment_comments', :locals=> {:comment => @comment, :comments => @comments, :com_criteria => @team.com_criteria }, :layout => 'plan'}
      format.xml  { render :xml => @comments }
    end
  end    
  
  def comment_reply
    logger.debug "GET comments for comment_reply id: #{params[:comment_id]} (comment_reply)"
  
    # comment_comments only exist under the question comments, so use the com's parent_id as question_id
    @comment = Comment.find(params[:comment_id])
    ## If this comment's parent is a comment, parent_type==3, then use its parent as the target - comments only go one deep
    #@comment = Comment.find(@comment.parent_id) if @comment.parent_type == 3

    case @comment.parent_type
      when 3
        #@comment.class.name == 'Comment'
        @parent = Comment.find(@comment.parent_id)
      when 13
        @parent = TalkingPoint.find(@comment.parent_id)        
    end
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:team_id=>@comment.team_id}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    
    
    @team = Team.find(team_id)
    
    text = %Q|[quote="#{@comment.author.first_name} #{@comment.author.last_name}"]#{@comment.text}[/quote]|

    respond_to do |format|
      format.js { render :partial => 'comment_reply', :locals=> {:comment => @comment, :comments => [@comment], :parent => @parent, :text => text, :com_criteria => @team.com_criteria }, :layout => false}
      #format.html { render :partial => 'comment_reply', :locals=> {:comment => @comment, :comments =>[@comment], :parent => @parent, :text => text, :com_criteria => @team.com_criteria}, :layout => false} unless !request.xhr?
      format.html { render 'comment_reply', :locals=> {:comment => @comment, :comments =>[@comment], :parent => @parent, :text => text, :com_criteria => @team.com_criteria }, :layout => 'plan'}
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
    comment = Comment.find(params[:comment_id])
    case comment.parent_type
      when 1
        type = 'question'
      when 3 
    	  type = 'comments'
     	when 13 
    		type = 'talking_points'
    end
    flash[:errors].each() {|attr, msg| comment.errors.add(attr, msg)} unless flash[:errors].nil?
    respond_to do |format|
      format.js { render :action => 'edit', :locals => {:comment => comment, :type => type }, :layout=>false}
      format.html { render :action => 'edit', :locals => {:comment => comment, :type => type }, :layout=>'plan'}
    end
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
  
  def cancel_comment_form
    case 
      when params[:act] == 'comment_comments'
        com = Comment.find(params[:id])
        redirect_to( question_worksheet_path(com.parent_id))
      when params[:act] == 'talking_point_comments'
        tp = TalkingPoint.find(params[:id])
        redirect_to( question_worksheet_path(tp.question_id))
      when params[:t] == 'question'
        redirect_to( question_worksheet_path(params[:id]))
      when params[:t] == 'comments'
        redirect_to( comment_comments_path(params[:id]))
      when params[:t] == 'talking_points'
        redirect_to( talking_point_comments_path(params[:id]))
    end
  end
  
  def create_talking_point_comment
    logger.debug "Comment.create_talking_point_comment"
    
    talking_point = TalkingPoint.find(params[:talking_point_id])
    
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:talking_point_id=>talking_point.id}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end
    
    
    @comment = talking_point.comments.create(:member=> @member, :text => params[:text], :parent_type => 13, :parent_id => params[:talking_point_id])
    
    respond_to do |format|
      if @comment.errors.empty?
        format.js { render 'comment_for_talking_point', :locals=>{:comment=>@comment, :members => [@member], :question_id => @comment.talking_point.question_id} }
        format.html { render :partial=> 'plan/comment', :locals=>{:comment=>@comment, :members => [@member]} } if request.xhr?
        format.html { redirect_to( talking_point_comments_path(@comment.parent_id), :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.js { render 'comment_for_question_errors', :locals=>{:comment=>@comment} }
        format.html { render :text => 'comment save failed' } if request.xhr?
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def create_comment_comment
    logger.debug "Comment.create_comment_comment"

    par_com = Comment.find(params[:comment_id])
    
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:team_id=>par_com.team_id}, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/private' }
          format.html { render 'shared/private', :layout => 'plan' }
        end
      end
      return
    end

    if par_com.parent_type == 1 # if parent is a comment under a question, then make this a child to that comment
      @comment = par_com.comments.create(:member=> @member, :text => params[:text], :parent_type => 3, :parent_id => params[:comment_id])
    else # otherwise, make this a sibling to the parent, a child to the parent's parent
      @comment = par_com.comments.create(:member=> @member, :text => params[:text], :parent_type => par_com.parent_type, :parent_id => par_com.parent_id )
    end
    respond_to do |format|
      if @comment.errors.empty?
        format.js { render 'comment_for_comment', :locals=>{:comment=>@comment, :members => [@member], :comment_id => @comment.parent_id } }
        format.html { render :partial=> 'plan/comment', :locals=>{:comment=>@comment, :members => [@member]} } if request.xhr?
        format.html { 
          par_com = Comment.find(@comment.id)
          if par_com.parent_type == 3 # a comment under a question
            redirect_to( comment_comments_path(par_com.parent_id), :notice => 'Comment was successfully created.') 
          elsif par_com.parent_type == 13 # a comment under a talking_point          
            redirect_to( talking_point_comments_path(par_com.parent_id), :notice => 'Comment was successfully created.') 
          end
        }

        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.js { render 'comment_for_comment_errors', :locals=>{:comment=>@comment} }
        format.html { render :text => 'comment save failed' } if request.xhr?
        format.html { render :action => "new" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    comment = Comment.find(params[:comment_id])
    comment.member = @member
    respond_to do |format|
      if comment.update_attributes(params[:comment])
        format.html { 
          # look at parent to determine where to redirect to
          # options
          # question_worksheet_path(comment.question)
          # comment_comments_path(params[:id]))
          # talking_point_comments_path(params[:id]))
          case
            when comment.parent_type == 1 
              redirect_to( question_worksheet_path(comment.parent_id), :notice => 'Comment was successfully updated.') 
            when comment.parent_type == 3
              comment = Comment.find(comment.parent_id)
              case
                when comment.parent_type == 1 
                  redirect_to( comment_comments_path(comment.id), :notice => 'Comment was successfully updated.' )
                when comment.parent_type == 13 
                  redirect_to( talking_point_comments_path(comment.parent_id), :notice => 'Comment was successfully updated.' )
              end  
            when comment.parent_type == 13
              redirect_to( talking_point_comments_path(comment.parent_id), :notice => 'Comment was successfully updated.' )
          end
        }  
        format.js { render :partial => 'update_comment', :locals => {:comment => comment} }
        format.xml  { head :ok }
      else
        format.html { redirect_to edit_comment_path(comment), :flash => { :errors => comment.errors} }
        format.xml  { render :xml => comment.errors, :status => :unprocessable_entity }
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
