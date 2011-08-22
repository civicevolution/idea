class QuestionsController < ApplicationController
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
  
  def what_do_you_think
    logger.debug "Question#what_do_you_think because user did not select a radio button"
    
    respond_to do |format|
      format.js { render 'what_do_you_think_must_select' }
      #format.html { render :partial=> 'plan/comment', :locals=>{:comment=>@comment, :members => [@member]} } if request.xhr?
      #format.html { redirect_to(@comment, :notice => 'Comment was successfully created.') }
      #format.xml  { render :xml => @comment, :status => :created, :location => @comment }
    end
    
  end
  
  def worksheet
    logger.debug "Question#worksheet"

    @question = Question.find(params[:question_id])
    @team = @question.team
    
    allowed,message = InitiativeRestriction.allow_action(@team.initiative_id, 'view_idea_page', @member)
    if !allowed
      if @member.id == 0
        flash[:pre_authorize_uri] = request.request_uri
        flash[:notice] = "Please sign in"
        render :template => 'welcome/must_sign_in', :layout => 'welcome'
        return
      else
        render :template => 'idea/private_page'
        return
      end
    end
    
    @question.get_talking_point_ratings(@member)
    
    # I need to fake the talking point data like this: talking_point.rating_votes = [5,3,1,4,2]
    fake_ratings = [ [12,4,1,1,2], [9,3,3,4,2], [9,0,2,4,6], [7,3,5,3,8], [3,3,1,0,1] ]

    fake_preference_votes = [7,5,4,2,1]
    fake_my_ratings = [1,2,3,1,2]
    fake_my_preference = [true, true, false, true, false]
    ind = 0

    @question.top_talking_points.each do |tp| 
      tp.rating_votes = fake_ratings[ind]
      tp.preference_votes = fake_preference_votes[ind]
      tp.my_rating = fake_my_ratings[ind]
      tp.my_preference = fake_my_preference[ind]
      ind+=1
    end  

    render :template=> 'questions/worksheet', 
      :locals => {:question => @question, :questions => @team.questions.sort{|a,b| a.order_id <=> b.order_id}, }, 
      :layout => request.xhr? ? false : 'plan'
    
    #:locals => {:question => @question, :questions => @team.questions, :question_counter => @question.order_id, :commenting_members => @question.commenting_members},
    #render :partial=> 'question', :collection => questions, :locals => {:questions => questions}
    #render :text => 'render the question partial'
  end

  protected
  
  QUESTIONS_CONTROLLER_PUBLIC_METHODS = ['worksheet']
  
  def authorize
    #debugger
    unless QUESTIONS_CONTROLLER_PUBLIC_METHODS.include? request[:action]
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
