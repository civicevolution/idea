class IdeasController < ApplicationController
  skip_before_filter :authorize, :only => [ :theming_page, :view_idea_details]
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
    question = Question.find(params[:question_id])
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


  def view_idea_details
    idea = nil
    #debugger
    if params[:act] == 'review_unrated_ideas'
      idea = Question.find(params[:question_id]).unrated_ideas(@member.id).limit(1)
      if idea.empty?
        idea = nil
      else
        idea = idea[0]
      end
      
    else
      idea = Idea.find(params[:idea_id])
      if params[:nav]
        # get the next or first sibling idea
        new_ideas = Idea.where(parent_id: idea.parent_id, is_theme: idea.is_theme, order_id: idea.order_id + 1)
        if new_ideas.empty?
           new_ideas = Idea.where(parent_id: idea.parent_id, is_theme: idea.is_theme, order_id: 1)
        end
        idea = new_ideas[0]
      end
    end
    
    respond_to do |format|
      if !idea.nil?
        idea.current_member = @member
        format.js { render 'ideas/details', locals: { idea: idea} }
        format.html { render 'ideas/details', layout: "plan", locals: { idea: idea} }
        #format.json { render json: @idea, status: :created, location: @idea }
      else
        format.js { render 'ideas/idea_not_found' }
        format.html { render 'ideas/idea_not_found' }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def add_comment
    idea = Idea.find(params[:idea_id])    
    comment = idea.comments.new(text: params[:text], member_id: @member.id, team_id: idea.question.team_id,
      parent_type: 20, parent_id: idea.id, question_id: idea.question_id, member: @member )
    #comment = Comment.includes(:author).find(1207)
    
    respond_to do |format|
      if comment.save  # true
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
      ctr = 0
      order_string = params[:ordered_ids].map{|o| "(#{ctr+=1},#{o})" }.join(',')
      
      sql = %Q|UPDATE ideas SET parent_id = #{idea_id}, order_id = new_order_id FROM ( SELECT * FROM (VALUES #{order_string}) vals (new_order_id,idea_id)	) t WHERE id = t.idea_id|
      logger.debug "Use sql: #{sql}"
      ActiveRecord::Base.connection.update_sql(sql)    
      
      respond_to do |format|
        format.js { render 'ideas/theme_ideas_order_ok', locals: { idea: idea} }
        #format.html { redirect_to @idea, notice: 'Idea was successfully created.' }
        #format.json { render json: @idea, status: :created, location: iidea }
      end
    rescue
      respond_to do |format|
        format.js { render 'ideas/theme_ideas_order_errors', locals: {idea: idea} }
        #format.html { render action: "new" }
        #format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /ideas
  # POST /ideas.json
  def create

    question = Question.find(params[:question_id])
    @idea = question.ideas.new(text: params[:text], is_theme: false, member_id: @member.id, team_id: question.team_id, visible: true, version: 1, current_member: @member)

    respond_to do |format|
      if @idea.save
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
