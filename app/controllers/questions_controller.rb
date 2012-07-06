class QuestionsController < ApplicationController
  skip_before_filter :authorize, :only => [ :summary, :worksheet, :all_comments, :all_talking_points, :old_data ]
  
  # GET /questions
  # GET /questions.xml
  def index
    @questions = Question.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    @question = Question.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = Question.new(params[:question])

    respond_to do |format|
      if @question.save
        flash[:notice] = 'Question was successfully created.'
        format.html { redirect_to(@question) }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(params[:question])
        flash[:notice] = 'Question was successfully updated.'
        format.html { redirect_to(@question) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
  end
  
  def add_talking_point
    logger.debug "Question#add_talking_point"
    logger.debug "Create question talking_point with text: #{params[:text]}"
    @talking_point = Question.find(params[:question_id]).talking_points.create(:member=> @member, :text => params[:text])
    respond_to do |format|
      if @talking_point.errors.empty?
        format.js { render 'talking_points/talking_point_for_question', :locals=>{:talking_point=>@talking_point, :question_id => @talking_point.question_id} }
        format.html { redirect_to( question_worksheet_path(@talking_point.question_id), :notice => 'Talking point was successfully created.') }
      else
        format.js { render 'talking_points/talking_point_for_question_errors', :locals=>{:talking_point=>@talking_point} }
        format.html { 
          flash[:worksheet_error] = @talking_point.errors
          flash[:params] = params
          redirect_to( what_do_you_think_path(params[:question_id]) )
        }
      end
    end
  end
  
  def add_comment
    logger.debug "Create question comment with text: #{params[:text]}"
    @comment = Question.find(params[:question_id]).comments.create(:member=> @member, :text => params[:text], :parent_type => 1, :parent_id => params[:question_id], :question_id => params[:question_id])
    respond_to do |format|
      if @comment.errors.empty?
        format.js { render 'comments/comment_for_question', :locals=>{:comment=>@comment, :members => [@member], :question_id => @comment.parent_id} }
        format.html { redirect_to( question_worksheet_path(@comment.parent_id), :notice => 'Comment was successfully created.') }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        format.js { render 'comments/comment_for_question_errors', :locals=>{:comment=>@comment} }
        format.html { 
          flash[:worksheet_error] = @comment.errors
          flash[:params] = params
          redirect_to( what_do_you_think_path(params[:question_id]) )
        }
      end
    end
    
  end
  
  def new_talking_points
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id => params[:question_id]}, 'view_idea_page', @member)
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
    
    @question = Question.find(params[:question_id])
    if !request.xhr?
      @question['talking_points_to_display'] = @question.top_talking_points
      @question['talking_points_to_display'] += @question.remaining_new_talking_points( @question['talking_points_to_display'].map(&:id), @member.last_visits[@question.team_id.to_s])
      worksheet
    else
      talking_points_to_display = @question.remaining_new_talking_points( params[:ids].split('-'), @member.last_visits[@question.team_id.to_s])
      TalkingPoint.get_and_assign_stats( @question, talking_points_to_display, @member )
      
      render :question_talking_points, :layout => false
      
    end
  end

  def all_comments
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id => params[:question_id]}, 'view_idea_page', @member)
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
    
    @question = Question.find(params[:question_id])
    if !request.xhr?
      @question['comments_to_display'] = @question.comments
      worksheet
    else
      @question['comments_to_display'] = @question.comments
      @question.get_talking_point_ratings(@member)
      render :question_comments, :layout => false
    end
  end

  def summary
    question ||= Question.find_by_id(params[:question_id])
    if question.nil?
      render :template => 'team/proposal_not_found', :layout=> 'plan'
      return
    end    
    
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id => params[:question_id]}, 'view_idea_page', @member)
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
    
    # I might want to trim this back to just get the stats I need
    question.member = @member
    #question.assign_new_content
    
    # FIX this to be done only when needed
    @default_answers = DefaultAnswer.select('id,checklist').where(:id=>question.default_answer_id) if question.curated_talking_points.size == 0
    			
    render :template=>'questions/summary', :formats => [:js], :layout => false, :locals=>{:question=>question}
  end
  
  
  def worksheet
    logger.debug "Question#worksheet"
    
    @question ||= Question.find_by_id(params[:question_id])
    if @question.nil?
      render :template => 'team/proposal_not_found', :layout=> 'plan'
      return
    end    

    @team = @question.team
    
    allowed,message = InitiativeRestriction.allow_actionX(@team.initiative_id, 'view_idea_page', @member)
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
    
    @edit_tps_allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id => @question.id}, 'edit_talking_point', @member)
    @select_tps_allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id => @question.id}, 'curate_talking_points', @member)
    
    @question.member = @member
    
    @question['talking_points_to_display'] ||= @question.all_talking_points

    if !@question.curated_tp_ids.nil?
      # set the order according to question.curated_tp_ids and set as selected
      @question.curated_tp_ids.scan(/\d+/).reverse.each do |id|
        selected_tp = @question['talking_points_to_display'].detect{|tp| tp.id == id.to_i}
        if !selected_tp.nil?
          selected_tp.selected = true
          @question['talking_points_to_display'].delete_if{|tp| tp == selected_tp}
          @question['talking_points_to_display'].unshift(selected_tp)
        end
      end
    end
    @question.get_talking_point_ratings(@member)
    
    if flash[:unrecorded_talking_point_preferences]
      # if flash unrecorded_talking_point_preferences, show the check marks the user tried to save and reinforce message to only select 5
      flash[:unrecorded_talking_point_preferences].each do |id|
        @question['talking_points_to_display'].detect{ |tp| tp.id == id}.my_preference = true
      end
    end
    
    @channels = ["_auth_team_#{@team.id}"]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
      	
    render :template=> 'questions/worksheet', 
      :locals => {:question => @question, :questions => @team.questions.sort{|a,b| a.order_id <=> b.order_id}, }, 
      :layout => request.xhr? ? false : 'plan'
    
    ActiveSupport::Notifications.instrument( 'tracking', :event => 'Question worksheet', :params => params.merge(:member_id => @member.id, :team_id=>@team.id)) unless @member.nil? || @member.id == 0
  end
  
  def curate_tps
    updated,message = Question.update_curated_talking_point_ids(params[:question_id],params[:tp_ids],'manual',@member)
    if updated
      render :template=>'questions/curate_tps_ok', :formats => [:js], :layout => false
    else
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'curate_not_allowed', :locals => {:message=>message} }
          format.html { render 'curate_not_allowed', :layout => 'plan', :locals => {:message=>message} }
        end
      end
      return
    end

    # Do I need this?
    #render :template=>'questions/curate_failed', :formats => [:js], :layout => false, :locals=>{:question=>question}
  end
  
  def update_worksheet_ratings
    
    unrecorded_talking_point_preferences = Question.update_worksheet_ratings( @member, params )

    respond_to do |format|
      if true #@question.save
        format.html { 
          if unrecorded_talking_point_preferences.size == 0
            redirect_to( question_worksheet_path( params[:question_id] ), :flash => {:notice => 'Question worksheet ratings were successfully recorded'} )
          else
            redirect_to( question_all_talking_points_path( params[:question_id] ), :flash => {:unrecorded_talking_point_preferences => unrecorded_talking_point_preferences } ) 
          end
        }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def old_data
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id => params[:question_id]}, 'view_idea_page', @member)
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
    
    question = Question.find(params[:question_id])
    render 'old_data', :locals=>{:question => question}
  end

end
