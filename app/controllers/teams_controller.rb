class TeamsController < ApplicationController

  def edit_summary_form
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:team_id=>params[:team_id]}, 'edit_team_summary', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/forbidden', :locals => {:message => message} }
          format.html { render 'shared/forbidden', :locals => {:message => message}, :layout => 'plan' }
        end
      end
      return
    end

    team = Team.find(params[:team_id])
    proposal_idea = ProposalIdea.new :title => team.title, :text=> team.solution_statement
    
    respond_to do |format|
      format.html { render 'edit_summary_form', :locals => {:team_id => params[:team_id], :proposal_idea => proposal_idea, :edit => true}, :layout => 'plan'}
      format.xml  { render :xml => @team }
    end
  end

  def edit_summary_post
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:team_id=>params[:team_id]}, 'edit_team_summary', @member)
    if !allowed
      if @member.id == 0
        force_sign_in
      else
        respond_to do |format|
          format.js { render 'shared/forbidden', :locals => {:message => message} }
          format.html { render 'shared/forbidden', :locals => {:message => message}, :layout => 'plan' }
        end
      end
      return
    end
    
    team = Team.find(params[:team_id])
    old_title = team.title
    old_summary = team.solution_statement
    team.title = params[:proposal_idea][:title]
    team.solution_statement = params[:proposal_idea][:text]
    team.member = @member
    
    respond_to do |format|
      if team.save
        # send a notification email
        ProposalMailer.delay.review_team_summary_update(@member, team, old_title, old_summary, request.env["HTTP_HOST"], params[:_app_name] )
        
        format.js { render 'comment_for_talking_point', :locals=>{:comment=>@comment, :members => [@member], :question_id => @comment.talking_point.question_id} }
        format.html { redirect_to( plan_path(params[:team_id]), :notice => 'Title and summary were successfully updated.') }
      else
        format.js { render 'comment_for_question_errors', :locals=>{:comment=>@comment} }
        format.html { render :action => "new" }
      end
    end
  end

  def setup_form
    team = Team.find_by_id(params[:team_id]) || Team.new
    render :template=>'teams/setup_form', :locals=>{:team=>team}, :layout=>'plan'
    
    
  end
  
  def update_setup
    #debugger
    
    team = Team.find_by_id(params[:team_id]) || Team.new
    team.attributes = params[:team]
    team.problem_statement = ''
    team.member = Member.find(1)
    team_saved = team.save
    
    question_errors = {}
    if team_saved
      params.each do |key,value| 
        if key.match(/question_\d+/)
          #debugger
          question = Question.find_by_id(value[:id]) || Question.new
          question.attributes = value
          question.member_id = params[:team][:org_id]
          question.team_id = team.id
          logger.debug "XXXXXXXXXX question: #{question.inspect}"
          question.save        
          question_errors[question.id] = question.errors unless question.errors.empty?
        end
      end
    end
    
    team.errors.add(:base,"There were errors when saving the questions") unless question_errors.empty?
    flash[:team_errors] = team.errors unless team.errors.empty?
    flash[:question_errors] = question_errors unless question_errors.empty?
    
    flash[:notice] = 'Proposal data has been updated' if flash[:team_errors].nil? && flash[:question_errors].nil?

    redirect_to setup_team_form_path(team.id)

  end

  # GET /teams
  # GET /teams.xml
  def index
    @teams = Team.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teams }
    end
  end

  # GET /teams/1
  # GET /teams/1.xml
  def show
    @team = Team.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.xml
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end


  def show_team_pages
    logger.debug "show_team_pages"
    @team = Team.find(params[:id])
    @pages = @team.pages
    # get page items so I can get the order
    # Item.find_by_o_id_and_o_type(18,9)
    #@page_items = Item.find_all_by_o_id_and_o_type(@pages,9).sort {|a,b| a.order <=> b.order }
    @page_items = Item.find_all_by_o_type_and_team_id(9,params[:id]).sort {|a,b| a.order <=> b.order }
    #debugger
    @questions = @team.questions
    @question_items = Item.find_all_by_o_type_and_team_id(1,params[:id])

    respond_to do |format|
      format.html { render :action => "show_team_pages" }
    end
    
  end

  def add_a_page
     @team = Team.find(params[:id])
     logger.debug "add_a_page for team: #{@team.title}"
     # check for the team's item record and create one if not found
     team_item = Item.find_by_o_id_and_o_type(@team.id, 4)
     if team_item.nil?
       logger.debug "create a team item, team page and team info item"
       # create the item record
       team_item = Item.new :team_id=>@team.id, :o_id=> @team.id, :o_type=>4, :par_id=>0, :order=>0, :sib_id=>0, :ancestors=>'{0}', :target_id=>0, :target_type=>0
       team_item.save
       # create a team page and a team info item record
       page = Page.new :page_title=> "Team page", :chat_title=> 'team chat', :nav_title=> 'Team info', :par_id=>team_item.id
       page.save
       #team_page_item = Item.new :team_id=>@team.id, :o_id=> @page.id, :o_type=>9, :par_id=>team_item.id, :order=>0, :sib_id=>0, 
       #:ancestors=>"{0,#{team_item.id}}", :target_id=>0, :target_type=>0
       
       team_info_item = Item.new :team_id=>@team.id, :o_id=> @team.id, :o_type=>10, :par_id=>page.item_id, :order=>0, :sib_id=>0, 
          :ancestors=>"{0,#{team_item.id},#{page.item_id}}", :target_id=>0, :target_type=>0
      team_info_item.save
      
      # make sure this user is a member of the team
      member = TeamRegistration.find_by_member_id_and_team_id(session[:member_id],@team_id)
      if member.nil?
        tr = TeamRegistration.new :team_id=>@team.id, :member_id=>session[:member_id], :status=>'confirmed'
        tr.save
      end
     end
     logger.debug "Create the page record"
     # create a page record
     page = Page.new :page_title=> "title", :chat_title=> 'chat title', :nav_title=> 'nav title', :par_id=>team_item.id
     page.save
     #logger.debug "create the page item"
     # create an item record for the page
     #page_item = Item.new :team_id=>@team.id, :o_id=> page.id, :o_type=>9, :par_id=>team_item.id, :order=>0, :sib_id=>0, :ancestors=>"{0,#{team_item.id}}", :target_id=>0, :target_type=>0
     logger.debug "team with the new page"

     redirect_to :action => 'show_team_pages', :id => params[:id]
  end

  def add_a_question
     page = Page.find(params[:id])
     page_item = Item.find_by_o_id_and_o_type(page.id,9);
     logger.debug "add_a_question for page: #{page.nav_title}"
     # create a page record
     question = Question.new :member_id=>1, :text=>'Question text', :par_id=> page_item.id, :target_id=>0, :target_type=>0
     question.save
     redirect_to :action => 'show_team_pages', :id => page_item.team_id
  end



  def update_team_pages
    logger.debug "update_team_pages start"
    #debugger
    
    @team = Team.find(params[:team][:id])
    @team.attributes = params[:team]
    @team.save
    
    #@pages = params[:pages]
    #@keys = @pages.keys
    params[:pages].each {|key, value|
      #logger.debug "Process page id: #{key}"
      #logger.debug "value: #{value}"
      @page = Page.find(key)
      #logger.debug "1. page: #{@page.inspect}"
      @page.attributes = value
      #logger.debug "2. page: #{@page.inspect}"
      #debugger
      @page.save
      
      # update the pages item record with the new order number
      
      #logger.debug "order is #{value[:order]}"
      @item = Item.find_by_o_id_and_o_type(value[:id],9)
      @item.order = value[:order]
      @item.save

    }
    if params[:questions]
      params[:questions].each {|key, value|
        if value[:delete] && value[:delete] == 'on'
          logger.debug "delete question with id: #{key}"
          question = Question.find(key)
          question.destroy
        else
          logger.debug "Update question with id: #{key}" 
          question = Question.find(key)
          #debugger
          question.attributes = value
          question.save
         # item = Item.find_by_o_id_and_o_type(value[:id],1)
         # item.order = value[:order]
         # item.save
        end
      }
    end
    
    params[:id] = params[:team][:id]
    redirect_to :action => 'show_team_pages', :id => params[:id]
    #show_team_pages()
    logger.debug "update_team_pages completed"
      
  end
  
  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  # POST /teams.xml
  def create
    @team = Team.new(params[:team])

    respond_to do |format|
      if @team.save
        flash[:notice] = 'Team was successfully created.'
        format.html { redirect_to(@team) }
        format.xml  { render :xml => @team, :status => :created, :location => @team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.xml
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Team was successfully updated.'
        format.html { redirect_to(@team) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.xml
  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(teams_url) }
      format.xml  { head :ok }
    end
  end
  
  def rss
    @host = Initiative.first(:select=>'domain',:conditions=>"id = 2").domain
    @teams = Team.all(
    :select=>'id, team_members.cnt, launched, title, solution_statement, created_at',
    :joins => 'as t LEFT OUTER JOIN (SELECT team_id, COUNT(*) AS cnt FROM team_registrations GROUP BY team_id) AS team_members ON team_members.team_id = t.id',
    :conditions => 'initiative_id = 2'
    )
  end

end
