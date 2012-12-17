class IdeasController < ApplicationController
  skip_before_filter :authorize, :only => [ :theming_page, :question_post_its_wall, :theme_summary, :theme_summary, :view_idea_details]
  # GET /ideas
  # GET /ideas.json
  def index
    @ideas = Idea.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ideas }
    end
  end

  # GET /ideas/1
  # GET /ideas/1.json
  def show
    @idea = Idea.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @idea }
    end
  end

  # GET /ideas/new
  # GET /ideas/new.json
  def new
    @idea = Idea.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @idea }
    end
  end

  # GET /ideas/1/edit
  def edit
    @idea = Idea.find(params[:id])
  end
  
  def theming_page
    question = Idea.find_by_id_and_role(params[:question_id],3)
    respond_to do |format|
      if question
        format.js { render 'ideas/theming_page', locals: { question: question} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: @idea }
      else
        format.js { render 'ideas/question_not_found' }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end


  def question_post_its_wall
    question = Idea.find_by_id(params[:question_id])

    if params[:nav]
      # get the next or first sibling idea
      new_ideas = Idea.where(team_id: question.team_id, parent_id: question.parent_id, role: question.role, order_id: question.order_id + ( params[:nav]=='next' ? 1 : -1) )
      if new_ideas.empty?
         new_ideas = Idea.where(team_id: question.team_id, parent_id: question.parent_id, role: question.role).order('order_id').limit(1)
      end
      question = new_ideas[0]
    end
    
    respond_to do |format|
      if !question.nil?
        format.js { render 'ideas/question_post_its_wall', locals: { question: question } }
        #format.html { render 'ideas/details', layout: "plan", locals: { idea: idea} }
        #format.json { render json: @idea, status: :created, location: @idea }
      else
        format.js { render 'ideas/idea_not_found', locals: { idea: idea, question: question } }
        #format.html { render 'ideas/idea_not_found' }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  def theme_final_edit
    question = Idea.find_by_id_and_role(params[:question_id],3)
    
    respond_to do |format|
      if !question.nil?
        format.js { render 'ideas/theme_final_edit', locals: { question: question } }
        #format.html { render 'ideas/details', layout: "plan", locals: { idea: idea} }
        #format.json { render json: @idea, status: :created, location: @idea }
      else
        format.js { render 'ideas/idea_not_found', locals: { idea: idea, question: question } }
        #format.html { render 'ideas/idea_not_found' }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  def theme_summary
    question = Idea.find(params[:question_id])
    question.member = @member
    @team = question.team
    @project_coordinator = @team.org_id == @member.id
    respond_to do |format|
      format.js { render 'ideas/question_theme_summary', locals: { question: question } }
      format.html { render 'plan/question_theme_summary', layout: "plan", locals: { question: question} }
    end
  end

  def view_idea_details
    idea = nil
    question = nil
    #debugger
    if params[:act] == 'review_unrated_ideas'
      question = Idea.find_by_id_and_role(params[:question_id],3)
      question.member = @member
      unrated_ideas = question.unrated_ideas
      if unrated_ideas.count > 0
        idea = unrated_ideas[0]
      end
    elsif params[:act] == 'add_new_answer'
      idea = Idea.new role: 2
      idea.id = 0
      question = Idea.find_by_id_and_role(params[:question_id],3)
      idea.team = question.team
    elsif params[:act] == 'review_unrated_answers'
      question = Idea.find_by_id_and_role(params[:question_id],3)
      question.member = @member
      unrated_answers = question.unrated_answers
      if unrated_answers.count > 0
        idea = unrated_answers[0]
      end
    elsif params[:act] == 'theming_popup'
      idea = Idea.find(params[:idea_id])
      if idea.role == 1 && !idea.parent_id.nil? && idea.parent_id != 0
        constituent_idea = idea
        idea = Idea.find(constituent_idea.parent_id)
      end
    else
      idea = Idea.find(params[:idea_id])
      if params[:nav]
        # get the next or first sibling idea
        new_ideas = Idea.where(question_id: idea.question_id, parent_id: idea.parent_id, role: idea.role, order_id: idea.order_id + ( params[:nav]=='next' ? 1 : -1) )
        if new_ideas.empty?
           new_ideas = Idea.where(question_id: idea.question_id, parent_id: idea.parent_id, role: idea.role, order_id: 1)
        end
        idea = new_ideas[0]
      end
    end
    
    constituent_idea ||= nil
    if !idea.nil? && idea.role == 3
      question = idea
    end
    
    question ||= idea.question unless idea.nil?
    question.member = @member

    respond_to do |format|
      if !idea.nil?
        idea.member = @member
        format.js { 
          if idea.role == 1
            render 'ideas/idea_details', locals: { idea: idea, question: question } 
          elsif idea.role == 2
            render 'ideas/answer_details', locals: { idea: idea, question: question, constituent_idea: constituent_idea } 
          elsif idea.role == 3
            render 'ideas/question_discussion', locals: { idea: idea, question: question } 
          elsif idea.role == 4
            render 'ideas/summary_discussion', locals: { idea: idea } 
          else
            render 'ideas/details', locals: { idea: idea, question: question } 
          end
        }
        format.html { render 'ideas/details', layout: "plan", locals: { idea: idea} }
        #format.json { render json: @idea, status: :created, location: @idea }
      else
        format.js { render 'ideas/idea_not_found', locals: { idea: idea, question: question } }
        format.html { render 'ideas/idea_not_found' }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def add_comment
    idea = Idea.find(params[:idea_id])    
    comment = idea.comments.new(text: params[:text], member_id: @member.id, team_id: idea.team_id,
      parent_type: 20, parent_id: idea.id, question_id: idea.question_id, member: @member )
    #comment = Comment.includes(:author).find(1207)
    
    saved = comment.save
    if saved
      comment.add_attachments(params[:attachments])
      comment.attachments.each{|att| att[:url] = att.attachment(:original); att[:icon] = att.icon_url}
    end
    
    respond_to do |format|
      if saved  # true
        format.js { render 'ideas/comment_for_idea', locals: { idea: @idea, comment: comment} }
        format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        format.json { render json: @idea, status: :created, location: @idea }
      else
        format.js { render 'ideas/comment_for_idea_errors', locals: {idea: @idea, comment: comment} }
        format.html { render action: "new" }
        format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  def theme_ideas_order
    logger.debug "theme_ideas_reorder for idea #{params[:idea_id]} to new ordered_ids: params[:ordered_ids]"
    idea = nil
    begin
      
      if params[:idea_id] == 'unthemed_ideas'
        idea_id = 'null'
      elsif params[:idea_id] == 'parked_ideas'
        idea_id = 0
      elsif params[:idea_id]
        idea = Idea.find(params[:idea_id])
        idea_id = idea.id
      end

      success, message = Idea.reorder_siblings( idea_id, params[:ordered_ids], @member )
      
      respond_to do |format|
        if success
          format.js { render 'ideas/theme_ideas_order_ok', locals: { idea: idea} }
          #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
          #format.json { render json: @idea, status: :created, location: iidea }
        else
          format.js { render 'ideas/theme_ideas_order_errors', locals: {message: message} }
        end
      end
    rescue Exception => e
      respond_to do |format|
        format.js { render 'ideas/theme_ideas_order_errors', locals: {message: e.message} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  def idea_visbility
    logger.debug "idea_visbility for idea #{params[:idea_id]} to params[:visible]"
    idea = Idea.find(params[:idea_id])

    respond_to do |format|
      if idea.update_attribute(:visible, params[:visible])
        format.js { render 'ideas/visiblity_update_ok', locals: { idea: idea} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/visiblity_update_ok_error', locals: { idea: idea} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_theme
    logger.debug "create_theme to right of col with id #{params[:par_id]} with idea #{params[:child_idea_id]}"

    idea = Idea.find(params[:child_idea_id])
new_text = %Q|**New answer**

* mouseover and click pencil to edit this answer
* drag to reorder|

    #new_text = 'new placeholder'
    new_theme = idea.question.ideas.create(text: new_text, role: 2, member_id: @member.id, order_id: 1,
      team_id: idea.question.team_id, question_id: idea.question.id, parent_id: idea.question.id, visible: true, version: 0, member: @member)
    idea.update_attribute(:parent_id, new_theme.id) 

    ordered_ids = new_theme.siblings.map(&:id)
    ordered_ids.delete(new_theme.id)
    if params[:par_id] == 'unthemed_ideas' || params[:par_id] == 'placeholder'
      ordered_ids = [new_theme.id] + ordered_ids
    else
      par_col_index = ordered_ids.index(params[:par_id].to_i);
      case
        when par_col_index == 0 && params[:side] == 'left'
           ordered_ids = [new_theme.id] + ordered_ids
        when params[:side] == 'left'
          ordered_ids.insert( par_col_index,  new_theme.id )
        else
          ordered_ids.insert( par_col_index + 1,  new_theme.id )
      end
      
    end
    # now I need to set the order
    Idea.reorder_siblings( new_theme.parent_id, ordered_ids, @member )
    
    respond_to do |format|
      if new_theme.save
        format.js { render 'ideas/create_theme_ok', locals: { new_theme: new_theme, idea: idea} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/create_theme_error', locals: {new_theme: new_theme, idea: idea} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_from_parent
    logger.debug "remove_from_parent id #{params[:idea_id]}"
    
    idea = Idea.find(params[:idea_id])
    idea.update_attribute(:parent_id, nil) 

    respond_to do |format|
      if idea.save
        format.js { render 'ideas/remove_from_parent_ok', locals: { idea: idea} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/remove_from_parent_errors', locals: { idea: idea} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def remove_theme
    logger.debug "remove_theme id #{params[:idea_id]}"
    
    idea = Idea.find(params[:idea_id])
    
    respond_to do |format|
      if idea.destroy
        format.js { render 'ideas/remove_theme_ok', locals: { idea: idea} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/remove_theme_error', locals: { idea: idea} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit_theme
    logger.debug "edit_theme id #{params[:idea_id]}"

    if params[:idea_id].to_i > 0
      idea = Idea.find(params[:idea_id])
    else
      idea = Idea.new
      idea.id = 0
    end
    
    # check if privileged
    auth = true
    
    respond_to do |format|
      if auth
        format.js { render 'ideas/theme_edit_form', locals: { idea: idea} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/edit_theme_error', locals: { idea: idea} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def edit_theme_post
    logger.debug "edit_theme id #{params[:idea_id]}"
    
    if params[:idea_id].to_i > 0
      idea = Idea.find(params[:idea_id])
      idea.text = params[:text]
      idea.version += 1
    else
      question = Idea.find( params[:question_id])
      idea = question.ideas.create(text: params[:text], role: 2, member_id: @member.id, order_id: 1,
        team_id: question.team_id, question_id: question.id, parent_id: question.id, visible: true, 
        version: 1, member: @member)

      ordered_ids = idea.siblings.map(&:id)
      ordered_ids.delete(idea.id)
      ordered_ids = ordered_ids + [idea.id]
      # now I need to set the order
      Idea.reorder_siblings( idea.parent_id, ordered_ids, @member )
      
    end
    
    respond_to do |format|
      if idea.save
        format.js { render 'ideas/edit_theme_ok', locals: { idea: idea} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/edit_theme_error', locals: { idea: idea} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def team_edit
    team = Team.find( params[:team_id] )
    # check if privileged
    auth = true
    respond_to do |format|
      if auth
        format.js { render 'ideas/team_edit_form', locals: { team: team} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/edit_theme_error' }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  

  def team_edit_post
    # check if privileged
    saved = false
    team = Team.find(params[:team_id])
    team.member = @member
    if params[:target] == 'title'
      team.title = params[:text]
      saved = team.save
      if saved
        team.idea.text = params[:text]
        saved = team.idea.save
      end
    elsif params[:target] == 'summary'
      team.solution_statement = params[:text]
      saved = team.save
    end
        
    respond_to do |format|
      if saved
        format.js { render 'ideas/team_edit_ok', locals: { team: team} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      else
        format.js { render 'ideas/edit_theme_error', locals: { team: team} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # POST /ideas
  # POST /ideas.json
  def create
    question = Idea.find_by_id_and_role(params[:question_id],3)
    question.member = @member
    @idea = question.ideas.new(text: params[:text], role: 1, member_id: @member.id, team_id: question.team_id, question_id: question.id, visible: true, version: 1, member: @member)
    @idea.parent_id = nil
    saved = @idea.save
    @idea.add_attachments(params[:attachments]) unless !saved
    
    respond_to do |format|
      if saved
        Idea.reorder_siblings( "null" , question.unthemed_ideas.map(&:id), Member.find(question.team.org_id) )
        format.js { render 'ideas/idea_for_question', locals: { idea: @idea, question: question} }
        format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        format.json { render json: @idea, status: :created, location: @idea }
      else
        format.js { render 'ideas/idea_for_question_errors', locals: {idea: @idea, question: question} }
        format.html { render action: "new" }
        format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /ideas/1
  # PUT /ideas/1.json
  def update
    @idea = Idea.find(params[:id])

    respond_to do |format|
      if @idea.update_attributes(params[:idea])
        format.html { redirect_to @idea, notice: 'Idea was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ideas/1
  # DELETE /ideas/1.json
  def destroy
    @idea = Idea.find(params[:id])
    @idea.destroy

    respond_to do |format|
      format.html { redirect_to ideas_url }
      format.json { head :no_content }
    end
  end
end
