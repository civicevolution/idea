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
  
  def all_talking_points
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
      @question['talking_points_to_display'] = @question.talking_points
      worksheet
    else
      talking_points_to_display = @question.remaining_talking_points( params[:ids].split('-') )
      TalkingPoint.get_and_assign_stats( @question, talking_points_to_display, @member )
      
      render :question_talking_points, :layout => false
    end
  end

  def new_comments
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
      @question['comments_to_display'] = 
        Comment.where("parent_id = :question_id AND parent_type = 1 AND created_at >= :last_visit", :question_id => @question.id, :last_visit => @member.last_visits[@question.team_id.to_s] )
      worksheet
    else
      @question['comments_to_display'] = @question.remaining_new_comments( params[:ids].split('-'), @member.last_visits[@question.team_id.to_s])
      @question.get_talking_point_ratings(@member)
      render :question_comments, :layout => false
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
      @question['comments_to_display'] = @question.remaining_comments( params[:ids].split('-') )
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
    
    #question['talking_points_to_display'] = params[:all] == 't' ? question.all_talking_points : question.top_talking_points
    #question.get_talking_point_ratings(@member)

    # FIX this to be done only when needed
    @default_answers = DefaultAnswer.select('id,checklist').where(:id=>question.default_answer_id) if question.curated_talking_points.size == 0
    
    			
    render :template=>'questions/summary.js', :layout => false, :locals=>{:question=>question}
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

    @question.member = @member
    @question.assign_new_content unless @member.nil? || @member.id == 0
    
    @question['talking_points_to_display'] ||= @question.show_new ? @question.new_talking_points : @question.top_talking_points
    @question['comments_to_display'] ||= @question.show_new ? @question.new_comments : @question.recent_comments
    
    # is this a request to highlight a specific item? If so, make sure it is present or add it
    if params[:t] == 'tp'
      tp_ids = @question['talking_points_to_display'].map(&:id)
      if !tp_ids.include?(params[:id].to_i)
        #logger.debug "********* Include talking_point #{params[:id]} and its new siblings"
        @new_talking_points = TalkingPoint.where("question_id = :question_id AND id NOT IN (:current_tp_ids) AND updated_at >= :last_visit", 
          :question_id => @question.id, :current_tp_ids => tp_ids, :last_visit => @member.last_visits[@question.team_id.to_s] )
        @question['talking_points_to_display'] += @new_talking_points
        # make sure I have the target now, if not, add it explicitly
        if !@question['talking_points_to_display'].map(&:id).include?(params[:id].to_i)
          @question['talking_points_to_display'] += [ TalkingPoint.find(params[:id]) ]
        end
      end

      @question['talking_points_to_display'].detect{|tp| tp.id == params[:id].to_i}['highlight'] = true
    elsif params[:t] == 'c'
      c_ids = @question['comments_to_display'].map(&:id)
      if !c_ids.include?(params[:id].to_i)
        new_comment = Comment.includes(:author).find(params[:id])
        #c_ids << new_comment.id
        #@question['comments_to_display'] += [new_comment]

        #logger.debug "new_comment: #{new_comment.inspect}"
        case new_comment.parent_type 
          when 1 # question comment
            @new_comments = Comment.includes(:author).where("parent_type = :parent_type AND parent_id = :parent_id AND id NOT IN (:current_c_ids) AND updated_at >= :last_visit", 
              :parent_type => new_comment.parent_type, :parent_id => new_comment.parent_id, :current_c_ids => c_ids, :last_visit => @member.last_visits[@question.team_id.to_s] )
            @question['comments_to_display'] += @new_comments
            # make sure I have the target now, if not, add it explicitly
            if !@question['comments_to_display'].map(&:id).include?(params[:id].to_i)
              @question['comments_to_display'] += [ Comment.find(params[:id]) ]
            end
            @question['comments_to_display'].detect{|c| c.id == params[:id].to_i}['highlight'] = true
            
          when 3 # comment on a comment under a question
            # make sure the parent comment exists, and if not, load it
            if !c_ids.include?(new_comment.parent_id)
              par_comment = Comment.includes(:author).find( new_comment.parent_id )
              c_ids << par_comment.id
              @question['comments_to_display'] += [par_comment]
            end

            # load the new_comment sibling comments
            @new_comments = Comment.includes(:author).where("parent_type = :parent_type AND parent_id = :parent_id AND id NOT IN (:current_c_ids) AND updated_at >= :last_visit", 
              :parent_type => new_comment.parent_type, :parent_id => new_comment.parent_id, :current_c_ids => c_ids, :last_visit => @member.last_visits[@question.team_id.to_s] )
            # make sure I have the target now, if not, add it explicitly
            if !@new_comments.map(&:id).include?(params[:id].to_i)
              @new_comments += [ Comment.find(params[:id]) ]
            end

            @new_comments.detect{|c| c.id == params[:id].to_i}['highlight'] = true
            
            # attach the comments to the comment 
            @question['comments_to_display'].detect{|c| c.id == new_comment.parent_id}['comments'] = @new_comments
            
            
          when 13 # comment on a talking point
            # load siblings and attach to the talking point
            # make sure the talking point is laoded
            # Do I want one new tp, or all of them?
            tp_ids = @question['talking_points_to_display'].map(&:id)

            if !tp_ids.include?( new_comment.parent_id )
              #logger.debug "********* Include talking_point #{params[:id]} and its new siblings"
              @new_talking_points = TalkingPoint.where("question_id = :question_id AND id NOT IN (:current_tp_ids) AND updated_at >= :last_visit", 
                :question_id => @question.id, :current_tp_ids => tp_ids, :last_visit => @member.last_visits[@question.team_id.to_s] )
              @question['talking_points_to_display'] += @new_talking_points
              # make sure I have the target now, if not, add it explicitly
              if !@question['talking_points_to_display'].map(&:id).include?(params[:id].to_i)
                @question['talking_points_to_display'] += [ TalkingPoint.find(params[:id]) ]
              end
            else
              #logger.debug "********* Talking point #{new_comment.parent_id} is already in the default data"
            end

            # get the comments
            @new_comments = Comment.includes(:author).where("parent_type = :parent_type AND parent_id = :parent_id AND updated_at >= :last_visit", 
              :parent_type => new_comment.parent_type, :parent_id => new_comment.parent_id, :last_visit => @member.last_visits[@question.team_id.to_s] )
            # make sure I have the target now, if not, add it explicitly
            if !@new_comments.map(&:id).include?(params[:id].to_i)
              @new_comments += [ Comment.find(params[:id]) ]
            end

            @new_comments.detect{|c| c.id == params[:id].to_i}['highlight'] = true
            
            # attach the comments to the talking point 
            @question['talking_points_to_display'].detect{|tp| tp.id == new_comment.parent_id}['comments'] = @new_comments
        end
        
      else
        #logger.debug "********* Comment #{params[:id]} is already in the default data"
        @question['comments_to_display'].detect{|c| c.id == params[:id].to_i}['highlight'] = true
      end
      
    end

    @question.get_talking_point_ratings(@member)
    
    if flash[:unrecorded_talking_point_preferences]
      # if flash unrecorded_talking_point_preferences, show the check marks the user tried to save and reinforce message to only select 5
      flash[:unrecorded_talking_point_preferences].each do |id|
        @question['talking_points_to_display'].detect{ |tp| tp.id == id}.my_preference = true
      end
    end
    
    #new_talking_point_ids = TalkingPoint.select('id').where("question_id = :question_id AND updated_at >= :last_visit", :question_id => @question.id, :last_visit => @member.last_visits[@question.team_id.to_s] )
    #@question.num_new_talking_points = (new_talking_point_ids.map(&:id) - @question['talking_points_to_display'].map(&:id)).size
    #
    #new_comment_ids = Comment.select('id').where("parent_id = :question_id AND parent_type = 1 AND created_at >= :last_visit", :question_id => @question.id, :last_visit => @member.last_visits[@question.team_id.to_s] )
    #@question.new_coms = (new_comment_ids.map(&:id) - @question['comments_to_display'].map(&:id)).size

    @channels = ["_auth_team_#{@team.id}", "_auth_inititive_#{params[:_initiative_id]}"]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    participant_actions = ActiveRecord::Base.connection.select_values("select distinct event_id from participation_events where member_id = #{@member.id} and question_id = #{@question.id} and event_id < 100").map{|e| e.to_i}
    @question['I_rated'] = participant_actions.include?(17) ? true : false
  	@question['I_favd'] = participant_actions.include?(19) ? true : false
  	@question['I_tpd'] = participant_actions.include?(3) ? true : false
		@add_tp = @rate_tp = @fav_tp = @com_tp = false
		if @question['talking_points_to_display'].size == 0
			@add_tp = true
		else 
			@rate_tp = true if @question['I_rated'] == false
			@fav_tp = true if @question['I_favd'] == false
			if !(@fav_tp || @rate_tp)
				if @question['I_tpd'] == false
					@add_tp = true
				else
					@com_tp = true
				end
			end
  	end
  	
    render :template=> 'questions/worksheet', 
      :locals => {:question => @question, :questions => @team.questions.sort{|a,b| a.order_id <=> b.order_id}, }, 
      :layout => request.xhr? ? false : 'plan'
    
    ActiveSupport::Notifications.instrument( 'tracking', :event => 'Question worksheet', :params => params.merge(:member_id => @member.id, :team_id=>@team.id)) unless @member.nil? || @member.id == 0
  end
  
  def curate_tps
    updated,message = Question.update_curated_talking_point_ids(params[:question_id],params[:tp_ids],'manual',@member)
    if updated
      render :template=>'questions/curate_tps_ok.js', :layout => false
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
    #render :template=>'questions/curate_failed.js', :layout => false, :locals=>{:question=>question}
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
