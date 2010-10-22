require 'recaptcha'
require 'yaml'
class TeamController < ApplicationController
  include ReCaptcha::AppHelper
  include LibCe


  def get_dev_css
    # open the file, read it and send it
    render :text => IO.read('public/stylesheets/ce1as.css'), :content_type => 'text/css'
  end

  def submit_proposal_idea
    logger.debug "submit_proposal_idea #{params.inspect}"
    
    member = Member.find(session[:member_id])

    restrictions_test,message = InitiativeRestriction.allow_action(params[:_initiative_id], 'suggest_idea', member)
    #logger.debug "Welcome::register restrictons test result #{restrictions_test} with message: #{message}"
    
    if !restrictions_test
      #logger.warn "failed restrictons test with message: #{message}"
      @saved = false
      @proposal_idea = ProposalIdea.new
      @proposal_idea.errors.add(:base, message)
    else
      @proposal_idea = ProposalIdea.new params[:proposal_idea]
      @proposal_idea.member_id = session[:member_id]
      @proposal_idea.initiative_id = params[:_initiative_id]
      @saved = @proposal_idea.save
    end
    
    
    if @saved
      
      ProposalMailer.deliver_submit_receipt(member, @proposal_idea, params[:_app_name] )
      ProposalMailer.deliver_review_request(member, @proposal_idea, request.env["HTTP_HOST"], params[:_app_name] )
    end
    
    respond_to do |format|
      if @saved
        format.html { render :action => "acknowledge_proposal_idea", :layout => false } if request.xhr?
      else
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end
    
  end

  def invite_friends
    logger.debug "invite_friends #{params.inspect}"
    
    member = Member.find(session[:member_id])
    team = Team.find(params[:team_id])
    
    @invite = InviteEmail.new :sender => member, :recipient_emails => params[:recipient_emails], :message=> params[:message]
    @invite.valid?

    if @invite.errors.empty? && params[:send_now] == 'true'
      # invite is valid and to be sent now - check the captcha before sending
      # I shortened the field name in form b/c it was removed by recaptcha
      params[:recaptcha_challenge_field] = params[:recaptcha_challenge]
      params[:recaptcha_response_field] =  params[:recaptcha_response]
      validate_recap(params, @invite.errors)
    end
    
    respond_to do |format|
      if @invite.errors.empty?
        if params[:send_now] != 'true'
          recipient =  @invite.recipients[0]
          logger.debug "Generate a sample email to #{recipient[:first_name]} at #{recipient[:email]}"
          @email = ProposalMailer.create_team_send_invite(member, recipient, @invite, team, request.env["HTTP_HOST"] )
          format.html { render :action => "team/preview_invite_request", :layout => false } if request.xhr?
          format.html { render :action => "team/preview_invite_request", :layout => 'welcome' }
        else
          @invite.recipients.each do |recipient|
            logger.debug "Send an email to #{recipient[:first_name]} at #{recipient[:email]}"
            ProposalMailer.deliver_team_send_invite(member, recipient, @invite, team, request.env["HTTP_HOST"] )
          end
          format.html { render :action => "team/acknowledge_invite_request", :layout => false } if request.xhr?
          format.html { render :action => "team/acknowledge_invite_request", :layout => 'welcome' }
          
        end
      else
        if !@invite.errors[:recipient_emails].nil? && @invite.errors[:recipient_emails].size() > 0 && request.xhr?
          format.html { render :action => "team/invite_request_email_errors", :layout => false }
        else
          format.json { render :text => [@invite.errors].to_json, :status => 409 }    
        end
      end
    end
    
  end

  
  def review_proposal_idea
    @proposal = ProposalIdea.find(params[:id])
    @submittor = Member.find_by_id(@proposal.member_id)
    respond_to do |format|
      if @submittor.nil? 
        format.html { render :text => "Please ignore this suggested idea -- the person that submitted this proposal is no longer a member", :layout => 'welcome' } 
      else
        format.html { render :action => "review_proposal_idea", :layout => 'welcome' } 
      end
    end
  end
  
  def approve_proposal_idea
    # publish this idea and notify the person that submitted the idea
    @proposal_idea = ProposalIdea.find(params[:id])
    @submittor = Member.find(@proposal_idea.member_id)
    
    # convert the idea into a team
    
    admin = Member.find_by_id(session[:member_id]);
    if !admin.nil? && admin.email == 'brian@civicevolution.org'
    
      logger.debug "create_team_from_proposal_idea for id: #{params[:id]}"
      #id refers to the proposal
      @proposal_idea = ProposalIdea.find(params[:id])

      if !@proposal_idea.launched
    
        # create a team record
        @team = Team.new :initiative_id => @proposal_idea.initiative_id, :org_id=>@proposal_idea.member_id, :title=>@proposal_idea.title, 
          :problem_statement=>'', :solution_statement=>@proposal_idea.text, :min_members=>4, :max_members=>25
        @team.save
        
        # create a team item record                   
        team_item = Item.new :team_id=>@team.id, :o_id=> @team.id, :o_type=>4, :par_id=>0, :order=>0, :sib_id=>0, :ancestors=>'{0}', :target_id=>0, :target_type=>0
        team_item.save
        
        # create a public discussion item
        pub_disc_item = Item.new :team_id=>@team.id, :o_id=> @team.id, :o_type=>11, :par_id=>team_item.id, :order=>0, :sib_id=>0, :ancestors=>"{0,#{team_item.id}}", :target_id=>0, :target_type=>0
        pub_disc_item.save        
        
        logger.debug "team was saved with id: #{@team.id}, create team_registration for member id: #{@team.org_id}"
        # make the organizer a team member
        tr = TeamRegistration.new(
          :team_id=>@team.id, 
          :member_id=>@team.org_id, 
          :status=>'confirmed',
          :accept_groundrules=>true,
          :host=>request.env["HTTP_HOST"]
        )
        tr.save
        logger.debug "tr.errors: #{tr.errors.inspect}" if tr.errors.size() > 0
    
        @proposal_idea.launched = true
        @proposal_idea.save
        
        #notify the author
        @host = request.env["HTTP_HOST"]
        ProposalMailer.deliver_approval_notice(@submittor, @proposal_idea, @team, @host )

        render :action => "proposal_idea_published", :layout => 'welcome'
      else
        logger.debug "This proposal: #{@proposal_idea} has already been converted into a team"
        render :text=> "This proposal: #{@proposal_idea} has already been converted into a team", :layout => 'welcome'
      end
    else
      render :action => "must_be_admin", :layout => 'welcome'
    end
  end
  
  def proposal
    # get the team data, questions, and answers and call render within the welcome layout
    @team_id = params[:id].to_i
    #begin
    #  @member_id = session[:member_id]
    #  @member = Member.find_by_id(@member_id)
    #  @mem_teams = TeamRegistration.find(:all,
    #    :select => 't.id, t.title, t.launched',
    #    :conditions => ['member_id = ?', @member.id],
    #    :joins => 'as tr inner join teams t on tr.team_id = t.id' 
    #  )
    #  
    #rescue
    #  @member_id = 0
    #  @member = nil
    #end
    
    @member_id = session[:member_id]
    @member = Member.find_by_id(@member_id)
    if @member.nil?
      @member_id = 0
      @member = nil
    end
    
    @team = Team.find_by_id(@team_id, :limit=>1)
    
    if @team.nil?
      render :template => 'team/proposal_not_found', :layout=>'welcome'
      return
    end

    @num_mems = TeamRegistration.count(:conditions => ['team_id = ?', @team_id])
    @last_ts = Team.find(@team_id).last_visit( @member_id )
    @items = @team.items
    @pages = @team.pages
    @questions = @team.questions
    # get the public. approved answers
    @answers_with_ratings = @team.answers_with_ratings( @member_id )

# get the comments for the public discussion areas only ( no rating information at this time)
    pub_disc_items, pub_coms, pub_com_resources, pub_com_authors = @team.public_disc_data(@member_id)
    
    # right now I have all items, so pub_disc_items is a duplication
    
    @comments_with_ratings = pub_coms
    @resources = pub_com_resources
    @com_authors = pub_com_authors

    @team_item = @items.detect {|i| i.o_id == @team_id && i.o_type == 4 } 
    @items_par_0_sorted = @items.find_all {|i| i.par_id == @team_item.id }.sort {|a,b| a.order <=> b.order }

    Activity.new(:member_id=>@member_id, :team_id=>@team_id, :action=>'proposal',
      :user_agent=>request.env["HTTP_USER_AGENT"], :cookie=>request.env["HTTP_COOKIE"], :ip=>request.remote_ip).save

    render :action => "proposal", :layout => 'welcome'

  end  
  
  def join_proposal_team
    logger.debug "join_proposal_team params: #{params.inspect}"
    
    @team = Team.find(params[:team_id])
    @member = Member.find(session[:member_id])
    restrictions_test,message = InitiativeRestriction.allow_action(@team.initiative_id, 'join_team', @member)
    #logger.debug "Welcome::register restrictons test result #{restrictions_test} with message: #{message}"
    
    if !restrictions_test
      #logger.warn "failed restrictons test with message: #{message}"
      saved = false
      @tr = TeamRegistration.new
      @tr.errors.add(:base, message)
    else
      @tr = TeamRegistration.new(
        :member_id=>session[:member_id],
        :team_id=>params[:team_id],
        :text=>params[:text],
        :accept_groundrules=>params[:accept_groundrules],
        :host=>request.env["HTTP_HOST"]
      )
      saved = @tr.save
    end
    
    respond_to do |format|
      if saved
        @host = request.env["HTTP_HOST"]
        @team.launched = true if @tr.team_just_launched # update launched status if the team was just launched
        format.html { render :action => "acknowledge_join_team", :layout => false } if request.xhr?
        if @tr.team_just_launched
          # an email was sent as the team was launched, don't need another one here to the member
          # but tell the admin
          ProposalMailer.deliver_team_just_launched(params[:_app_name], @team, @tr, @host )
        else
          ProposalMailer.deliver_team_join_confirmation(Member.find(@tr.member_id), @team, @tr, @host )
        end
      else
        format.json { render :text => [@tr.errors].to_json, :status => 409 }
      end
    end
    
    #begin
    #  @member_id = session[:member_id]
    #  @member = Member.find(@member_id)
    #rescue
    #  @member_id = 0
    #  @member = nil
    #end
    #
    #  if @member.nil?
    #    # sign in/register
    #    logger.debug "Member must sign in/register"
    #    format.json { render :text => [@answer.errors].to_json, :status => 500 } if request.xhr?
    #    render :action => "../welcome/signin_register", :layout => 'welcome'
    #  elsif @member.confirmed == false
    #    # request email confirmation
    #    format.json { render :text => [@answer.errors].to_json, :status => 500 } if request.xhr?
    #    
    #    logger.debug "Member must confirm"
    #    render :action => "../welcome/request_confirm", :layout => 'welcome'
    #  else
    #    logger.debug "Member signed in and confirmed"
    #    
    #    render :action => "join_team", :layout => 'welcome'
    #  end
    #end
    
   # @team = Team.find_by_id(@team_id)
  end
  
  
  #def create_team_workspace
  #  if session[:member_id] == 1
  #  
  #    logger.debug "create_team_workspace for id: #{params[:id]}"
  #    #id refers to the proposal
  #    @team = Team.find(params[:id])
  #    
  #    if !@team.launched
  #      @team.create_team_workspace
  #  
  #      render :template=>'teams/create_team_workspace', :layout=>'welcome'
  #    else
  #      logger.debug "This team: \"#{@team.title}\" has already been converted into a team workspace"
  #      render :text=> "This team: \"#{@team.title}\" has already been converted into a team workspace"
  #    end
  #  else
  #    render :text=> "Can't do it"
  #  end
  #end
  
  
  
  def get_templates

    @team = Team.new(:com_criteria=>'4..7', :res_criteria=>'3..8')
    strs = []
    strs.push '<div>'
    item = Item.new(:target_id => 1, :target_type => 11)
    @members = [ ]
    @items = [ ]
    @last_ts = Time.now
    old_ts = Time.local(2000,1,1)
    newer_ts = Time.local(2005,1,1)
     
    strs.push '<hr/><h3>Question w/ answer and idea</h3><hr/>'
    bs_idea_rating = BsIdeaRating.new(:member_id => session[:member_id], :created_at => old_ts, :updated_at => newer_ts)
    bs_idea_rating[:q_id] = 1
    bs_idea_rating[:my_vote] = 3
    bs_idea_rating[:text] = 'Idea for the template'
    bs_idea_rating[:average] = 4.5
    bs_idea_rating[:count] = 7
    @bs_ideas_with_ratings = [ bs_idea_rating ] 

    answer_rating = AnswerRating.new(:created_at => old_ts, :updated_at => old_ts)
    answer_rating[:q_id] = 1
    answer_rating[:my_vote] = 2
    answer_rating[:text] = 'answer for the template'
    answer_rating[:ver] = 2
    answer_rating[:average] = 4.5
    answer_rating[:count] = 7
    @answers_with_ratings = [answer_rating]

   question = Question.new(:text => 'Question for template', :created_at => old_ts, :updated_at => old_ts, :answer_criteria=>'5..15',:idea_criteria=>'6..12')
   question.id = 1

   strs.push '<div class="item Question">'
   strs.push render_to_string( :partial => 'question', :object => question,
     :locals => { :item => item} )
   strs.push '</div>'

   strs.push '<hr/><h3>comment</h3><hr/>'
   comment_rating = ComRating.new(:created_at => old_ts, :updated_at => newer_ts)

    comment_rating[:anonymous] = 'f'
    comment_rating[:member_id] = session[:member_id]
    comment_rating[:pic_id] = 10011
    comment_rating[:text] = 'Comment for template'
    comment_rating[:my_vote] = 0
    comment_rating[:up] = 3
    comment_rating[:down] = 1
    @resources = [ Resource.new ]  
   
   @com_authors = [ ]
    strs.push '<div class="item Comment">'
    strs.push render_to_string( :partial => 'comment', :object => comment_rating,
      :locals => { :item => item, :down => 0, :up => 0,  :rated => 0})
    strs.push '</div>'


    strs.push '<hr/><h3>chat message</h3><hr/>'
    strs.push render_to_string(:partial => 'chat')
    
    #strs.push '<hr/><h3>add_comment_combined</h3><hr/>'
    #
    #strs.push render_to_string(:partial => 'add_comment_combined', :locals => { :id => 1, :label=>'Please add your comment'})
    #
    #strs.push '<hr/><h3>add_answer</h3><hr/>'
    #
    #strs.push render_to_string(:partial => 'add_answer', :locals => { :question=>question })
    
    
    strs.push '</div>'
    render :text => strs.join('') #, :content_type => 'text/xml'
    
  end

  def get_templates2
    
    
    strs = []
    strs.push '<div>'

    strs.push render_to_string(:partial => 'add_comment_combined', :locals => { :id => 1, :label=>'Please add your comment'})
    
    strs.push '</div>'
    render :text => strs.join('') #, :content_type => 'text/xml'
    
  end


  
  def answer_history_demo
    logger.debug "answer_history_demo, params[:mode]: #{params[:mode]}, id: #{params[:id]}"
    
    if params[:mode]
      begin
        if params[:mode] == 'add'
          # create answer and add par_id and member_id
          @answer = Answer.new
          @answer.store_initial_values  
          @answer.attributes = params[:answer]        
          @answer.par_id = params[:par_id]
          @answer.member_id = session[:member_id]
          @answer.insert_mode = params[:insert_mode]
        else
          @answer = Answer.find(params[:id])
          @answer.store_initial_values
          @answer.attributes = params[:answer]
        end
        @saved = @answer.save  # in place of saved for testing
      rescue TeamAccessDeniedError
        logger.debug "TeamAccessDeniedError error"
        redirect_to :action => 'access_denied'
        return
      end
    elsif params[:id]
      @answer = Answer.find(params[:id])
    end
    
    itemDiff = ItemDiff.new(:item => @answer)
    @htmlDiffs = itemDiff.show_history unless !params[:id]

    # render a response
    respond_to do |format|
      if @saved
        @target_item = Item.find_by_o_id_and_o_type(@answer.id,2)
        @target = get_target(@target_item)
        params[:mode] = 'update'
        logger.debug "answer was saved successfully"
        flash[:notice] = 'Answer was successfully created.'
        format.html { render :action => "answer_history_demo" } 
      else
        if ! params[:mode] && params[:id]
          @target_item = Item.find_by_o_id_and_o_type(@answer.id,2)
          @target = get_target(@target_item)
          params[:mode] = 'update'
        elsif !params[:mode]
          @target_item = Item.find(33)
          @target = get_target(@target_item)
          params[:mode] = 'add'
        else
          @target_item = Item.find(params[:par_id])
          @target = get_target(@target_item)          
        end
        format.html { render :action => "answer_history_demo" } 
      end
    end
  end

  def item_history
    #logger.debug "params[:id]: #{params[:id]}"
    @target = get_target( Item.find_by_o_id_and_o_type(params[:id], 2) )
    #logger.debug "@target: #{@target.inspect}"
    itemDiff = ItemDiff.new(:item => @target)
    #logger.debug "itemDiff: #{itemDiff.inspect}"
    @htmlDiffs = itemDiff.show_history unless !params[:id]
    respond_to do |format|
      format.html { render :action => "item_history", :layout => false } if request.xhr?
      format.html { render :action => "item_history" } 
    end
  end

  def answer_rating
    logger.debug "answer_rating: #{params.inspect}"
    name = params.keys.grep(/bs_rating/)[0]
    # what if name is nil?
    score = params[name]

    @answer_id = name.match(/(\d+)/)[1]
    member_id =  session[:member_id]
    logger.debug "save answer_rating :member_id: #{member_id}, :answer_id => #{@answer_id}, :score => #{score}"
    rating = AnswerRating.find_by_answer_id_and_member_id(@answer_id, member_id) 

    if rating.nil?
      rating = AnswerRating.new :member_id => member_id, :answer_id => @answer_id, :rating => score
    else
      rating.rating = score
    end
    rating.save

    #calculate new score, count and average
    @average = AnswerRating.average(:rating, :conditions => ['answer_id = ?', @answer_id ])
    @count = AnswerRating.count(:rating, :conditions => ['answer_id = ?', @answer_id ])

    serialized = sendApeNotification({:type=>'rating', :channel=>"team#{rating.team_id}", :data => {:type => 'answer', :average=>@average, :count=>@count, :id=>@answer_id }},session);

    respond_to do |format|
      format.html { render :text => serialized } if request.xhr? # ajaxmode gets the update via APE
      #format.js
      format.html { request.referer ?  redirect_to(request.referer + "\#item_rater_#{@item_id}") :  redirect_to( :action => 'index' ) }
    end
  end
  
  def com_rate

    member_id = session[:member_id]
    com_id = params[:thumbsup_id]
    rating = params[:thumbsup_rating]

    logger.debug "com_rate member: #{member_id}, com_id: #{com_id}, rating: #{rating}"

    com_rating = ComRating.find_by_comment_id_and_member_id(com_id, member_id) 
    if com_rating.nil?
      com_rating = ComRating.new :member_id => member_id, :comment_id => com_id, :up => rating.to_i > 0 ? 1 : 0, :down => rating.to_i > 0 ? 0 : 1 
    else
      com_rating.up = rating.to_i > 0 ? 1 : 0
      com_rating.down = rating.to_i > 0 ? 0 : 1
    end
    com_rating.save

    #calculate new score, count and average
    @up = ComRating.sum(:up, :conditions => ['comment_id = ?', com_id ])
    @down = ComRating.sum(:down, :conditions => ['comment_id = ?', com_id ])
    
    serialized = sendApeNotification({:type=>'com_rate', :channel=>"team#{com_rating.team_id}", :data => {:up=>@up, :down=>@down, :com_id=>com_id, :my_vote => rating }},session);

    respond_to do |format|
      format.html { render :text => serialized } if request.xhr? # ajaxmode gets the update via APE    
      #format.html { request.referer ?  redirect_to(request.referer + "\#item_rater_#{@item_id}") :  redirect_to( :action => 'index' ) }
    end

  end
  
  def index
    @team_id = params[:id].to_i

    logger.debug "Check for team id: #{@team_id}"  
    @team = Team.find_by_id(@team_id)
    if @team.nil?
      render :template => 'team/proposal_not_found', :layout=>'welcome'
      return
    end

    ##logger.debug "Check for team = private"  
    ## if this team is not available, show a message
    #if @team.status == 'private'
    #  render :text => "This team is currently private"
    #  render :template => 'team/proposal_is_private', :layout=>'welcome'
    #  return
    #end
    
    logger.debug "Check for team registration"  

    # does user have access?
    team_member = TeamRegistration.find_by_member_id_and_team_id( session[:member_id] , @team_id)
    if team_member.nil?
      render :template => 'team/not_a_team_member', :layout=>'welcome'
      return
    end
      
    orig_team = @team
    
#    # get my question id, if any
#    private_question_id = team_member.access_details.match(/\d+/)
#    
#    logger.info "private_question_id: #{private_question_id}"
#    if private_question_id
#      private_question_id = private_question_id[0].to_i  
#      @page_channel = 'page' + Item.find_by_o_id_and_o_type(private_question_id,1).ancestors.match(/(\d+),(\d+),(\d+)/)[3]
#      @private_page = private_question(private_question_id)
#    else
      @private_page = ''
#    end
    
    # recover the instance variables after the detour to the negotiation page
    @team = orig_team  
    @team_id = @team.id
    member_id = session[:member_id]
    @member = Member.find(member_id)
    
    @last_ts = Team.find(@team_id).last_visit( member_id )
    #@last_ts = Time.local(2010,3,27)

    @members = @team.members 
    @items = @team.items
    @pages = @team.pages
    @questions = @team.questions
    @answers_with_ratings = @team.answers_with_ratings( member_id )
    @bs_ideas_with_ratings = @team.bs_ideas_with_ratings( member_id )
       
    @comments_with_ratings = @team.comments_with_ratings( member_id )
    author_ids = @comments_with_ratings.collect {|c| c.member_id }.uniq
    member_ids = @members.collect {|m| m.id }.uniq
    pub_authors = @team.public_authors(author_ids - member_ids)
    #mem_authors = @members.collect { |m| {:id=> m.id, :first_name=>m.first_name, :last_name=>m.last_name, :ape_code=> m.ape_code, :pic_id => m.pic_id,:member => 't' }  }
    @com_authors = @members + pub_authors
    
    @resources = @team.resources
    
    # get checklist items - from file for now
    yml = YAML.load_file 'config/check_list_items.yaml'
    @check_list_items = []
    yml.each_pair { |key, rec|
      # construct an array of checklistitems as if form db
      item = CheckListItem.new  :team_id=> 10007, :title=> rec['title'], :description=> rec['description'], :par_id=> rec['par_id'], :order=> rec['order'],
        :completed=> rec['completed'], :request_details=> rec['request_details'], :discussion=> rec['discussion'] == false ? 0 : 1, :created_at=> Time.now
      item.id = rec['id']
      @check_list_items.push item
    } 
    
    yml = YAML.load_file 'config/team_roles.yaml'
    @roles = []
    yml.each_pair { |key, rec| @roles.push rec }

    @team_item = @items.detect {|i| i.o_id == @team_id && i.o_type == 4 } 
    @items_par_0_sorted = @items.find_all {|i| i.par_id == @team_item.id }.sort {|a,b| a.order <=> b.order }
    Activity.new(:member_id=>session[:member_id], :team_id=>@team_id, :action=>'team index',
      :user_agent=>request.env["HTTP_USER_AGENT"], :cookie=>request.env["HTTP_COOKIE"], :ip=>request.remote_ip).save
    
  end
  
  def private_question(arg)
    
    @question_id = arg || params[:id].to_i
    logger.info "Check for question id: #{@question_id}"  
    
    @q_item = Item.find_by_o_id_and_o_type(@question_id,1)
    
    if @q_item.nil?
      render_to_string :text => "The question #{@question_id} you requested does not exist. Please return to the home page and sign in: http://uos.civicevolution.org"
      return
    end

    @team = Team.find_by_id(@q_item.team_id)
    if @team.nil?
      render_to_string :text => "The team data you requested does not exist. Please return to the home page and sign in: http://uos.civicevolution.org"
      return
    end
    @team_id = @team.id
    
    # does user have access?
    team_member = TeamRegistration.find_by_member_id_and_team_id( session[:member_id] , @team_id)
    if team_member.nil?
      render_to_string :text => "You do not have access to this team"
      return
    end
    
    
    if @team.status == 'private' && team_member.access_details != 'q' + @question_id.to_s
      # check if this users' details give access
      render_to_string :text => "This team/question is currently private and you have not been granted access to it"
      return
    end
    
    logger.info "Build the question data for question id #{@question_id}"  
    # for now, just collect all the data for the team and let the template select what is needed
    
    @last_ts = Team.find(@team_id).last_visit( session[:member_id] )
    
    @members = @team.members 
    @items = @team.items
    @pages = @team.pages
    @questions = @team.questions
    @answers = @team.answers
    @comments = @team.comments
    @resources = @team.resources
    @ratings = @team.average_ratings
    @thumbs_ratings = @team.thumbs_ratings
    @my_thumbs_ratings = @team.my_thumbs_ratings( session[:member_id] )
    
    @lists = @team.lists
    @list_items = @team.list_items

    #@team_item = @items.detect {|i| i.o_id == @team_id && i.o_type == 4 } 
    @items_par_0_sorted = @items.find_all {|i| i.id == @q_item.par_id }
    #@page_item = @items.detect {|i| i.id == @q_item.par_id }

    #@test_links = render_to_string :partial => 'test_links'

    # alright, I have the data 
    # now show it without a layout

    Activity.new(:member_id=>session[:member_id], :team_id=>@team_id, :action=>'private_question',
      :user_agent=>request.env["HTTP_USER_AGENT"], :cookie=>request.env["HTTP_COOKIE"], :ip=>request.remote_ip).save
    
    render_to_string :action=>'private_question', :layout=>false
    
  end
  
  
  
  def proposal_transcript
    @team_id = 10000
    @team = Team.find(@team_id)
    @members = @team.members 
    @items = @team.items
    @questions = @team.questions
    @answers = @team.answers
    @comments = @team.comments
    @resources = @team.resources
    @ratings = @team.average_ratings
    @thumbs_ratings = @team.thumbs_ratings
    @my_thumbs_ratings = @team.my_thumbs_ratings( session[:member_id] )
    @team_item = @items.detect {|i| i.o_id == @team_id && i.o_type == 4 } 
    @items_par_0_sorted = @items.find_all {|i| i.par_id == @team_item.id }.sort {|a,b| a.order <=> b.order }
    @test_links = render_to_string :partial => 'test_links'
    
    @lists = @team.lists
    @list_items = @team.list_items
  end
  

  def edit_answer
    @answer = Answer.find(params[:id])
    @target_item = Item.find_by_o_id_and_o_type(params[:id],2)
    logger.debug "edit_answer call add_answer"
    params[:mode] = 'update'  
    params[:id] = params[:par_id]  
    add_answer
  end


  def add_answer
    @mode = params[:mode] || 'add'
    #get the target and make sure the member has access to post 
    @target_item = Item.find(params[:id]) unless @target_item
    
    @team = check_member_team_access( @target_item.team_id )

    if @team 
      logger.debug "Member is authorized to add answer to team"
      logger.debug "add_answer, add another answer to this question: #{@target_item.id}"
    else
      logger.debug "Member is NOT authorized to add answer to team"

      redirect_to :action => 'access_denied'
      return
    end
    
    @target = get_target(@target_item)
    logger.debug "question is #{@target.text}"
    
    #@target_item.team_id = 122
    logger.debug "team_id: #{@target_item.team_id }"
    
    # get a new answer object for the view
    @answer ||= Answer.new(params[:answer])
    

    respond_to do |format|
      format.html { render :action => "add_answer" }
      format.xml  { render :xml => @answer }
    end

    
  end
  
# ===================
# = create_answer  
# = get new Answer instance
# validation checks team access, and sets team_id
# after_create will generate an Item for this Answer and save it
# ===================  
  
  def create_answer
    logger.debug "create the answer"
    
    begin
      if params[:mode] == 'add'
        # create answer and add par_id and member_id
        @answer = Answer.new
        @answer.par_id = params[:par_id]
        @answer.member_id = session[:member_id]
        @answer.insert_mode = params[:insert_mode]
      else
        @answer = Answer.find(params[:id])
      end
      # store initial values so the revision history will work
      @answer.store_initial_values  
      @answer.attributes = params[:answer]
   
      logger.debug "try to save the answer"
      @saved = @answer.save  # in place of saved for testing
      logger.debug "answer saved = #{@saved}"
    rescue TeamAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'access_denied'
      return
    end

    ajaxMode = request.xhr? || params[:post_mode] == 'ajax'
    # render a response
    respond_to do |format|
      if @saved
        logger.debug "answer was saved successfully"
        flash[:notice] = 'Answer was successfully created.'

        # I need to provide these items when the partial is used to generate html for APE
        item = Item.find_by_o_id_and_o_type(@answer.id,@answer.o_type) 
        @answer.item_id = item.id
        @members = [ Member.find( session[:member_id] )]

        if params[:mode] != 'add'
          logger.debug "Get the score data for this answer which is being edited"
          rating = AnswerRating.answer_ratings(@answer.id,session[:member_id])[0]
          average = rating.nil? ? 0 : rating.average
          count = rating.nil? ? 0 : rating.count
          my_vote = rating.nil? ? 0 : rating.my_vote
        else
          average = count = my_vote = 0
        end
        
        # send JSON data to ape, it will be converted to js
        serialized = sendApeNotification({:type=>'ans_json', :channel=>"team#{item.team_id}", :debug_save_id => item.id,
          :data => {:mode=>params[:mode], :item_id=>item.id, :par_id=>item.par_id, :sib_id=>item.sib_id, :item => item, :data => @answer, 
          :average => average, :count => count, :my_vote => my_vote, :remaining_ans => @answer.remaining_answers }},session);

        #format.html { render :text => "ok" } if ajaxMode # ajaxmode gets the update via APE
        format.html { render :text => serialized } if ajaxMode # ajaxmode gets the update via APE
        format.html { redirect_to( :action => 'index' ) }
        format.xml  { render :xml => @answer, :status => :created, :location => @answer }
      else
      
        if ajaxMode
          format.json { render :text => [@answer.errors].to_json, :status => 409 }
          #format.html {render :partial => 'team/error', :object => @answer, :status => 500 } 
        else
          @target_item = Item.find(params[:par_id])
          @target = get_target(@target_item)

          format.html { render :action => "add_answer",:status => 409 }
          format.xml  { render :xml => @answer.errors, :status => :unprocessable_entity }
        end    
      end
    end
  end
  
  def delete_answer
    begin
      page_channel = 'page' + Item.find_by_o_id_and_o_type(params[:id],2).ancestors.match(/(\d+),(\d+),(\d+)/)[3]
      @answer = Answer.find(params[:id])
      @answer.destroy
    rescue EditAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'edit_access_denied'
      return
    end

    @deleteMode = @answer.itemDestroyed ? 'full' : 'partial'
    sendApeNotification({:type=>'ans_json', :channel=>"team#{@answer.team_id}", :page_channel=>"#{page_channel}", 
    :data => {:item_type=>'Answer', :mode=>'delete_' + @deleteMode, :item_id=>@answer.item_id }},session);
    
    respond_to do |format|
      format.json { render :action => "delete_report" }
      format.html { redirect_to( :action => 'index' ) }
      format.xml  { head :ok }
    end
  end
  
  def edit_comment
    logger.debug "edit_comment for params[:id]: #{params[:id]}"
    @comment = Comment.find(params[:id])
    @resource = @comment.resource
    @target_item = Item.find_by_o_id_and_o_type(params[:id],3)
    if @resource.nil?
      params[:option] = 'simple'
    elsif @resource.resource_file_name
      params[:option] = 'upload'
    elsif @resource.link_url
      params[:option] = 'link'
    else
      params[:option] = 'simple'
    end
    logger.debug "edit_comment call add_comment params[:option]: #{params[:option]}"
    params[:mode] = 'update'    
    add_comment
  end  
  
  def add_comment
    #get the target and make sure the member has access to post 
    @target_item = Item.find(params[:id]) unless @target_item
    params[:mode] ||= 'add'
    
    @team = check_member_team_access( @target_item.team_id )

    if @team 
      logger.debug "Member is authorized to add comment to team"
      logger.debug "add_comment, add another comment to this item: #{@target_item.inspect}"
    else
      logger.debug "Member is NOT authorized to add comment to team"

      redirect_to :action => 'access_denied'
      return
    end

    @target = get_target(@target_item)
    logger.debug "target is #{@target.inspect}"
    # get a new comment object for the view
    @comment = Comment.new(params[:comment]) unless @comment
    @resource = Resource.new(params[:resource]) unless @resource
    
    logger.debug "options = #{params[:option]}"
    respond_to do |format|
      format.html { render :action => "add_comment_with_upload" } if params[:option] =~ /upload/
      format.html { render :action => "add_comment_with_link" } if params[:option] =~ /link/
      format.html { render :action => "add_comment" } if params[:option] =~ /simple/
      format.html # new.html.erb
      format.xml  { render :xml => @answer }
    end
  end

  # ===================
  # = create_comment
  # = get new Comment instance
  # validation checks team access, and sets team_id
  # after_create will generate an Item for this Comment and save it
  # ===================  

  def create_comment
    logger.debug "create_comment mode: #{params[:mode]}"
    logger.debug "Check if the user wants to add a link or upload a file option: #{params[:option]}"
    
    # check if user wants to link or upload, if so, call back to add_comment
    if params[:option] 
      params[:id] = params[:par_id]
      logger.debug "call add_comment with params[:option]: #{params[:option]}"
      add_comment
      return
    end

    save_com = true
    if params[:mode] == 'add'
      logger.debug ":mode == 'add'"
      # create comment and add par_id and member_id
      @comment = Comment.new(params[:comment])
      @comment.par_id = params[:par_id]
    
      @comment.member_id = session[:member_id]
      @comment.insert_mode = params[:insert_mode]
    else
      logger.debug "!add, :mode is #{params[:mode]}"
      @comment = Comment.find(params[:id])
      
      # I need to make sure this comment belongs to user
      if @comment.member_id != session[:member_id]
        @comment.errors.add_to_base("You cannot edit this comment.")
        logger.warn "user #{session[:member_id]} tried to edit comment id: #{params[:id]}"
        save_com = false
        @saved = false
      else
        @comment.attributes = params[:comment]
        logger.debug "after attributes, comment: #{@comment.inspect}"
      end
    end
    
    if save_com
      begin
        Comment.transaction do        
          logger.debug "try to save the comment"
          comSave = @comment.save  
          logger.debug "comSave; #{comSave}"        
          #debugger if !comSave
        
        
          if params[:resource_type] == 'simple'
            logger.debug "simple resource"
            # no resource to save
            # if there was a resource, destroy it
            res = @comment.resource
            if res
              res.destroy()
              @comment.resource
            end
            logger.debug "do comSave"
            @saved = comSave
          else
            if params[:mode] == 'add'
              @resource = Resource.new(params[:resource])
              @resource.member_id = session[:member_id]
              @resource.resource_type = params[:resource_type]
            else
              @resource = @comment.resource
              logger.debug "Determine if I need to destroy the old resource: #{@resource}"
              # if I am changing the type of resource away from upload file,
              # destroy the record to eliminate the downloaded file
              if !@resource || (params[:resource_type] == 'link' && @resource.resource_file_name) || (params[:resource_type] == 'upload' && @resource.link_url)
                @resource.destroy() unless !@resource
                @resource = Resource.new(params[:resource])
                @resource.member_id = session[:member_id]
                @resource.resource_type = params[:resource_type]
              else
                @resource.attributes = params[:resource]
              end
            end
            #debugger
            logger.debug "resource: #{@resource.inspect}"
            @resource.team_id = @comment.team_id
            if comSave 
              @resource.comment = @comment
              resSave = @resource.save
            else
              @resource.comment_id = 0 # so I can do validation
              @resource.valid?
              resSave = false
            end
            if !comSave || !resSave
              @saved = false
              raise ActiveRecord::Rollback
            else
              @saved = true
            end
          end # end if resource
        end  # end of transaction
      rescue ActiveRecord::Rollback
        #don't need to do anything
      rescue TeamAccessDeniedError
        logger.debug "TeamAccessDeniedError error"
        redirect_to :action => 'access_denied'
        return
      end # of begin block
    end # end of save_com
    
    logger.debug "XXX 1 after save com/resource, @saved: #{@saved}"

    ajaxMode = request.xhr? || params[:post_mode] == 'ajax'
    # render a response
    respond_to do |format|
      if @saved
        logger.debug "comment was saved successfully"
        flash[:notice] = 'Comment was successfully created.'
        #format.html { render :action => "save_comment" } #{ redirect_to(@answer) }
        
        # I need to provide these items to generate html for APE
        item = Item.find_by_o_id_and_o_type(@comment.id,@comment.o_type) 
        @resources = [ @resource || Resource.new ]   
        member = Member.find( session[:member_id] )
        @members = [ member ]
        
        author = escape_json_text( @comment.anonymous ? 'Anonymous' : (member.nil? ? 'Unknown author' : member.first_name + ' ' + member.last_name) )
        author_url = @comment.anonymous ? '/images/members_default/36/m.jpg' : (member.nil? ? '/images/members_default/36/m.jpg' : member.photo.url('36')) 
       # time_ago = escape_json_text( time_ago_in_words(@comment.created_at) + ' ago' )
        #debugger

        res_link = render_to_string :partial => 'comment_resource_link' if !@resource.nil?
        
        # get the score data: up, down, my_vote
        if params[:mode] != 'add'
          rating = ComRating.com_ratings(@comment.id,session[:member_id])[0]
          up = rating.nil? ? 0 : rating.up
          down = rating.nil? ? 0 : rating.down
          my_vote = rating.nil? ? 0 : rating.my_vote
        else
          up = down = my_vote = 0
        end

        # send JSON data to ape, it will be converted to js
        serialized = sendApeNotification({:type=>'com_json', :channel=>"team#{@comment.team_id}", :debug_save_id => item.id,
          :data => {:mode=>params[:mode], :item_id=>item.id, :par_id=>item.par_id, :sib_id=>item.sib_id, :item => item, :author => author, :pic_url=> author_url, :pic_id=>member.pic_id, :data => @comment, 
          :resource => @resources[0], :resource_link => res_link, :up => up, :down => down, :my_vote => my_vote }},session);

        #format.html { render :partial => 'comment', :object => @comment, 
        #  :locals => { :item => item, :count => 0, :score => 0,  :t_count => 0, :t_score => 0, :rated => 0}  } if ajaxMode
        #format.html { render :text => "ok" } if ajaxMode # ajaxmode gets the update via APE
        format.html { render :text => serialized } if ajaxMode # ajaxmode gets the update via APE
        format.html { redirect_to( :action => 'index' ) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        logger.debug "XXX 2 com/res was not saved, params[:resource_type]: #{params[:resource_type]}"
        @resource.errors.each() {|attr, msg| @comment.errors.add(attr, msg)} unless @resource.nil?
        if ajaxMode
          format.json { render :text => [@comment.errors].to_json, :status => 409 }
          #combine the errors from resources into comment errors so they will all be displayed
          #format.html {render :partial => 'team/error', :object => @comment, :status => 400, :locals => { :resources => @resources} }
        else
          @target_item = Item.find(params[:par_id])
          @target = get_target(@target_item)
          params[:option] = params[:resource_type]
          format.html { 
            params[:id] = params[:par_id]
            add_comment; 
            return; 
          }
          format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        end
      end
    end
  end  
  
  def delete_comment
    logger.debug "delete_comment"
    begin
      page_channel = 'page' + Item.find_by_o_id_and_o_type(params[:id],3).ancestors.match(/(\d+),(\d+),(\d+)/)[3]
      @comment = Comment.find(params[:id])
      @comment.destroy
    rescue EditAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'edit_access_denied'
      return
      
    end
   
    @deleteMode = @comment.itemDestroyed ? 'full' : 'partial'
    sendApeNotification({:type=>'com_json', :channel=>"team#{@comment.team_id}", :page_channel=>"#{page_channel}", 
    :data => {:item_type=>'Comment', :mode=>'delete_' + @deleteMode, :item_id=>@comment.item_id }},session);
    
    respond_to do |format|
      format.json { render :action => "delete_report" }
      format.html { redirect_to( :action => 'index' ) }
      format.xml  { head :ok }
    end
  end
  
# ==========
# = Question =
# ==========  

  def edit_question
    @question = Question.find(params[:id])
    @target_item = Item.find_by_o_id_and_o_type(params[:id],1)
    logger.debug "edit_question call add_question"
    params[:mode] = 'update'    
    params[:id] = params[:par_id]
    add_question
  end
  
  def add_question
    @mode = params[:mode] || 'add'
    #get the target and make sure the member has access to post 
    @target_item = Item.find(params[:id]) unless @target_item
    
    logger.debug "@target_item: #{@target_item.inspect}"

    @team = check_member_team_access( @target_item.team_id )

    if @team 
      logger.debug "Member is authorized to add question to team"
      logger.debug "add_question, add another question to this item: #{@target_item.inspect}"
    else
      logger.debug "Member is NOT authorized to add question to team"

      redirect_to :action => 'access_denied'
      return
    end

    @target = get_target(@target_item)
    logger.debug "target is #{@target.inspect}"
    # get a new question object for the view
    @question ||= Question.new(params[:question])

    respond_to do |format|
      format.html { render :action => "add_question" }
      format.xml  { render :xml => @question }
    end


  end

# ===================
# = create_question 
# = get new Question instance
# validation checks team access, and sets team_id
# after_create will generate an Item for this Question and save it
# ===================  

  def create_question
    logger.debug "create the question"

    begin
      if params[:mode] == 'add'
        # create comment and add par_id and member_id
        @question = Question.new
        @question.par_id = params[:par_id]
        @question.member_id = session[:member_id]
        @question.insert_mode = params[:insert_mode]
      else
        @question = Question.find(params[:id])
      end      
      # store initial values so the revision history will work
      @question.store_initial_values  
      @question.attributes = params[:question]

      logger.debug "try to save the question"
      @saved = @question.save  # in place of saved for testing
    rescue TeamAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'access_denied'
      return
    end
    
    ajaxMode = request.xhr? || params[:post_mode] == 'ajax'
    # render a response
    respond_to do |format|
      if @saved
        logger.debug "question was saved successfully"
        flash[:notice] = 'Question was successfully created.'

        # I need to provide these items when the partial is used to generate html for APE
        item = Item.find_by_o_id_and_o_type(@question.id,@question.o_type) 
        @members = [ Member.find( session[:member_id] )]

        # send JSON data to ape, it will be converted to js
        sendApeNotification({:type=>'ques_json', :channel=>"team#{item.team_id}", 
          :data => {:mode=>params[:mode], :item_id=>item.id, :par_id=>item.par_id, :sib_id=>item.sib_id, :item => item, 
          :data => @question, :score => 0, :count => 0, :rated => 0 }},session);
        

        #format.html { render :partial => 'question', :object => @question, 
        #  :locals => { :item => item, :count => 0, :score => 0,  :rated => 0}  } if ajaxMode
        format.html { render :text => "ok" } if ajaxMode # ajaxmode gets the update via APE
        format.html { redirect_to( :action => 'index' ) }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
      else

        @target_item = Item.find(params[:par_id])
        @target = get_target(@target_item)

        format.html { render :action => "add_question" }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
  def delete_question
    begin
      page_channel = 'page' + Item.find_by_o_id_and_o_type(params[:id],1).ancestors.match(/(\d+),(\d+),(\d+)/)[3]
      @question = Question.find(params[:id])
      @question.destroy
    rescue EditAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'edit_access_denied'
      return
    end
    
    @deleteMode = @question.itemDestroyed ? 'full' : 'partial'
    sendApeNotification({:type=>'ques_json', :channel=>"team#{@question.team_id}", :page_channel=>"#{page_channel}", 
    :data => {:item_type=>'Question', :mode=>'delete_' + @deleteMode, :item_id=>@question.item_id }},session);

    respond_to do |format|
      format.json { render :action => "delete_report" }
      format.html { redirect_to( :action => 'index' ) }
      format.xml  { head :ok }
    end
  end
  
  
  

  def edit_list_item
    @list_item = ListItem.find(params[:id])
    @list_id = @list_item.list_id
    logger.debug "edit_answer call add_answer"
    params[:mode] = 'update'  
    add_list_item
  end


  def add_list_item
    logger.debug "add_list_item"
    @mode = params[:mode] || 'add'
    @list_item = ListItem.new unless @list_item
    @list_id = params[:id] unless @list_id
    @target_list = List.find(@list_id)
    @target_item = Item.find_by_o_id_and_o_type(@list_id,7)
    @team = check_member_team_access( @target_item.team_id )

    if @team 
      logger.debug "Member is authorized to add list_items to team"
      logger.debug "add_list_item, add another answer to this question: #{@target_item.id}"
    else
      logger.debug "Member is NOT authorized to add list_items to team"
      redirect_to :action => 'access_denied'
      return
    end

    @target = get_target(@target_item)
    logger.debug "target list is #{@target.text}"
    logger.debug "team_id: #{@target_item.team_id }"

    # get a new answer object for the view
    @list_item ||= ListItem.new(params[:list_item])

    @target = get_target(@target_item)

    respond_to do |format|
      format.html { render :action => "add_list_item" }
      format.xml  { render :xml => @list_item }
    end


  end

# ===================
# = create_answer  
# = get new Answer instance
# validation checks team access, and sets team_id
# after_create will generate an Item for this Answer and save it
# ===================  

  def create_list_item
    logger.debug "create the list_item"

    begin
      if params[:mode] == 'add'
        # create lsit_item and add par_id and member_id
        @list_item = ListItem.new
        @list_item.member_id = session[:member_id]
        @list_item.list_id = params[:list_id]
      else
        @list_item = ListItem.find(params[:id])
      end
      # store initial values so the revision history will work
      @list_item.store_initial_values  
      @list_item.attributes = params[:list_item]

      logger.debug "try to save the list_item"
      @saved = @list_item.save
    rescue TeamAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'access_denied'
      return
    end

    ajaxMode = request.xhr? || params[:post_mode] == 'ajax'
    # render a response
    respond_to do |format|
      if @saved
        logger.debug "ListItem was saved successfully"
        flash[:notice] = 'ListItem was successfully created.'

        # I need to provide these items when the partial is used to generate html for APE
        item = Item.find_by_o_id_and_o_type(@list_item.list_id,7) 
        @members = [ Member.find( session[:member_id] )]

        # send JSON data to ape, it will be converted to js
        sendApeNotification({:type=>'list_item_json', :channel=>"team#{item.team_id}", 
          :data => {:item_type=>'List%20Item', :mode=>params[:mode], :list_id=>@list_item.list_id, :data => @list_item }},session);
           
        format.html { render :text => "ok" } if ajaxMode # ajaxmode gets the update via APE
        format.html { redirect_to( :action => 'index' ) }
        format.xml  { render :xml => @answer, :status => :created, :location => @answer }
      else

        @target_item = Item.find(params[:par_id])
        @target = get_target(@target_item)

        format.html { render :action => "add_answer" }
        format.xml  { render :xml => @answer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def reorder_list_items
    @list = List.find(params[:id])
    @this_list_items = @list.list_items
  end
  
  def save_reordered_list_items
    list = List.find(params[:id])
    ids = list.reorder_list_items(params)

    team_id = Item.find_by_o_id_and_o_type(list.id,7).team_id
    
    sendApeNotification({:type=>'reorder_list_item_json', :channel=>"team#{team_id}", :data => {:item_type=>'ListReorder', :id=>list.id, :item_ids=>ids }},session);

    respond_to do |format|
      format.json { render :text => "ok" }
      format.html { redirect_to( :action => 'index' ) }
      format.xml  { head :ok }
    end
    
  end
  
  
  def delete_list_item
    begin
      @list_item = ListItem.find(params[:id])
      @list_item.destroy
    rescue EditAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'edit_access_denied'
      return
    end

    @deleteMode = 'full'
    sendApeNotification({:type=>'list_item_json', :channel=>"team#{@list_item.team_id}", 
    :data => {:item_type=>'List%20Item', :mode=>'delete_' + @deleteMode, :id=>@list_item.id }},session);

    respond_to do |format|
      format.json { render :action => "delete_report" }
      format.html { redirect_to( :action => 'index' ) }
      format.xml  { head :ok }
    end
  end
  
  def list_item_history
    #logger.debug "params[:id]: #{params[:id]}"
    #@target = get_target( Item.find(params[:id]) )
    @target = ListItem.find_by_id(params[:id])
    #logger.debug "@target: #{@target.inspect}"
    itemDiff = ItemDiff.new(:item => @target)
    #logger.debug "itemDiff: #{itemDiff.inspect}"
    @htmlDiffs = itemDiff.show_history unless !params[:id]
    respond_to do |format|
      format.html { render :action => "item_history", :layout => false } if request.xhr?
      format.html { render :action => "item_history" } 
    end
  end      
  
###
### Chat functions  
###
  
  def chat_window
    render :partial => 'chat_window'
  end

  def page_chat_message
    #logger.debug "chat_message params: #{params.inspect}"
    # receive chat message from a client
    # validate it
    # if no chat session, create a new chat session
    # save it
    # disseminate it
    
    logger.debug "page_chat_message: #{params.inspect}"
    member = Member.find(session[:member_id])
    
    chat_msg = PageChatMessage.new({:member_id=>member.id, :page_id=>params[:page_id], :text=>params[:text] })
    saved = chat_msg.save
    
    #name = escape_json_text(member.first_name + ' ' + member.last_name)
    name = escape_json_text(member.first_name)

    respond_to do |format|
      if saved
        serialized = sendApeNotification({:type=>'chat', :channel=>"team#{chat_msg.team_id}", :data => {:text=>chat_msg.text, :name=>name, :pic_id=>member.pic_id, 
          :pic_url => member.photo.url('36'), :chat_msg_id=>chat_msg.id, :item_id=>params[:page_id] }},session);
        format.html { render :text => serialized } if request.xhr?       
      else
        format.json { render :text => [chat_msg.errors].to_json, :status => 409 }
      end
    end
    
  end
  
  def page_chat_transcript
    logger.debug "page_chat_transcript params[:id]: #{params[:id]}"
    # id is item_id, get o_id for the chat_session.id
    # is session_id a chat session? It might be a page
    @chat_messages, @chat_authors = PageChatMessage.get_transcript(session[:member_id],params[:id])
    
    respond_to do |format|
      if @chat_messages.class == String
        # an error string was returned
        format.html { render :text=> @chat_messages, :status=>200, :layout => false} if request.xhr?
        format.html { render :text=> @chat_messages, :status=>409} if request.xhr?  
      else
        format.html { render :action => "page_chat_transcript", :layout => false } if request.xhr?
        format.html { render :action => "page_chat_transcript" } 
      end
    end
    

  end

  def delete_chat_message
    logger.debug "delete chat_message params: #{params.inspect}"
    cm = ChatMessage.find_by_id_and_member_id(params[:id],session[:member_id])
    if !cm.nil?
      cm.update_attribute('text','This message deleted by author')
      cas = ChatActiveSession.find_by_chat_session_id(cm.chat_session_id)
      if !cas.nil?
        sendApeNotification({:type=>'chat', :channel=>"team#{cas.team_id}", 
        :data => {:action=>'delete', :text=>cm.text, :chat_msg_id=>cm.id }},session);
      end
    end
    respond_to do |format|
      format.json { render :text => "ok" }
      format.html { redirect_to( :action => 'index' ) }
      format.xml  { head :ok }
    end
    
  end
  
  def add_chat_message_to_list
    cm = ChatMessage.find_by_id(params[:id])
    if !cm.nil?
      # which list applies to this message?
      cas = ChatActiveSession.find_by_chat_session_id(cm.chat_session_id)
      params[:list_item] = {"anonymous"=>"false", "text"=>cm.text}
      params[:mode] = 'add'
      params[:post_mode] = 'ajax'
      params[:list_id] = cas.list_id
      logger.debug "Call create_list_item with params: #{params.inspect}"
      create_list_item
    end
  end
  
  def get_chat_active_summaries
    # return lists and list_items that are currently active
    #active_chats,active_lists,list_items = List.active_lists(params[:team_id],params[:id] == '' ? 'all' : params[:id])
    data = List.active_lists(params[:team_id],params[:id] == '' ? 'all' : params[:id])
    # return as json
    data = [data].to_json
    #data = escape_json_text(data)
    
    # return data as json
    render :text => data, :content_type => 'application/json'
    
  end
  
  def chat_transcript
    logger.debug "chat_transcript params[:id]: #{params[:id]}"
    # id is item_id, get o_id for the chat_session.id
    # is session_id a chat session? It might be a page
    item = Item.find_by_id(params[:id])
    if item.o_type != 5
      item = Item.find_by_o_type_and_par_id(5,params[:id])
    end
    chat_session_id = item.o_id
#    @chat_messages = ChatMessage.find_all_by_chat_session_id(chat_session_id, :order=> 'id')
    @chat_messages = ChatMessage.get_transcript(chat_session_id)

    respond_to do |format|
      format.html { render :action => "chat_transcript", :layout => false } if request.xhr?
      format.html { render :action => "chat_transcript" } 
    end
  end
  
  def access_denied
    
  end
  
  
# ===================
# = create_brainstorm_idea  
# = get new Answer instance
# validation checks team access, and sets team_id
# after_create will generate an Item for this Answer and save it
# ===================  
  
  def create_brainstorm_idea
    logger.debug "create the brainstorm_idea"
    
    begin
      if params[:mode] == 'add'
        # create answer and add par_id and member_id
        @bs_idea = BsIdea.new
        @bs_idea.member_id = session[:member_id]
      else
        @bs_idea = BsIdea.find( params[:idea_id] )
      end
      @bs_idea.attributes = params[:bs_idea]
   
      logger.debug "try to save the brainstorm_idea"
      
      @saved = @bs_idea.save  # in place of saved for testing
      
    rescue TeamAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'access_denied'
      return
    end

    ajaxMode = request.xhr? || params[:post_mode] == 'ajax'
    
    
    if params[:mode] != 'add'
      logger.debug "Get the score data for this answer which is being edited"
      rating = BsIdeaRating.idea_ratings(@bs_idea.id,session[:member_id])[0]
      average = rating.nil? ? 0 : rating.average
      count = rating.nil? ? 0 : rating.count
      my_vote = rating.nil? ? 0 : rating.my_vote
    else
      average = count = my_vote = 0
    end

    # render a response
    respond_to do |format|
      if @saved
        logger.debug "idea was saved successfully"
        flash[:notice] = 'Idea was successfully created.'

        # send JSON data to ape, it will be converted to js
        serialized = sendApeNotification({:type=>'bs_idea', :channel=>"team#{@bs_idea.team_id}", :debug_save_id => 'bs_' + @bs_idea.id.to_s,
          :data => {:mode=>params[:mode], :data => @bs_idea,:average => average, :count => count, :my_vote => my_vote}},session);
          
        format.html { render :text => serialized } if ajaxMode # ajaxmode gets the update via APE
        format.html { redirect_to( :action => 'index' ) }
        format.xml  { render :xml => @answer, :status => :created, :location => @answer }
      else
        # serialize the form errors and send back ajson
        
        if ajaxMode
          format.json { render :text => [@bs_idea.errors].to_json, :status => 409 }
        else
          # this code generates a static page with the target of the comment, the comment form, and the error data - for now I just want the error data
          @target_item = Item.find(params[:par_id])
          @target = get_target(@target_item)
          format.html { render :action => "add_answer" }
        end
      end
    end
  end
  
  def bs_rating
    logger.debug "rate the brainstorm_idea #{params.inspect}"
    name = params.keys.grep(/bs_rating/)[0]
    # what if name is nil?
    score = params[name]

    @bs_id = name.match(/(\d+)/)[1]
    member_id =  session[:member_id]
    logger.debug "save bs_rating :member_id: #{member_id}, :bs_id => #{@bs_id}, :score => #{score}"
    rating = BsIdeaRating.find_by_idea_id_and_member_id(@bs_id, member_id) 
    
    if rating.nil?
      rating = BsIdeaRating.new :member_id => member_id, :idea_id => @bs_id, :rating => score
    else
      rating.rating = score
    end
    rating.save
    
    #calculate new score, count and average
    @average = BsIdeaRating.average(:rating, :conditions => ['idea_id = ?', @bs_id ])
    @count = BsIdeaRating.count(:rating, :conditions => ['idea_id = ?', @bs_id ])
    
    serialized = sendApeNotification({:type=>'rating', :channel=>"team#{rating.team_id}", :data => {:type => 'bs_idea', :average=>@average, :count=>@count, :id=>@bs_id }},session);

    respond_to do |format|
      format.html { render :text => serialized } if request.xhr? # ajaxmode gets the update via APE
      #format.js
      format.html { request.referer ?  redirect_to(request.referer + "\#item_rater_#{@item_id}") :  redirect_to( :action => 'index' ) }
    end
  end

  
  def send_ape
    
    #serialized = sendApeNotification({:type=>'bs_idea', :channel=>"team#{10004}", 
    #  :data => {:mode=>params[:mode], :data => 
    #    {:id => 123, :question_id => 60, :member_id => 1, :text => "My new idea xmitd by APE #{Time.new}", :created_at => Time.new }
    #    }},session);
    #render :text => serialized 
    #return
    
#    serialized = sendApeNotification(
#      {
#        :type=>'com_json', 
#        :channel=>"team#{10004}", 
#        :data => {
#          :mode=>"add", 
#          :score=>1, :item_id=>1220, :rated=>0, :count=>0, 
#          :par_id=>789, 
#          :author=>"Brian%20Sullivan", 
#          :resource_link=>nil, 
#          :sib_id=>0, 
#          :data=> { :id => 310, :member_id => 1, :anonymous => false, :status => "ok", :text => "re I want to be PM, 2nd immediate child", :created_at => "2010-07-09 20:53:39", :updated_at => "2010-07-09 20:53:39"}, 
#          :item=>{:id => 1220, :team_id => 10004, :o_id => 310, :o_type => 3, :par_id => 789, :order => 1, :created_at => "2010-07-09 20:54:23", :updated_at => "2010-07-09 20:54:23", :sib_id => 0, :ancestors => [0,724,737,747,789], :target_id => nil}, 
#          :resource=>{:id => nil, :comment_id => nil, :member_id => nil, :title => nil, :description => nil, :link_url => nil, :resource_file_name => nil, :resource_file_size => nil, :resource_content_type => nil, :created_at => nil, :updated_at => nil}
#        }});

        logger.debug "send_ape, params: #{params.inspect}"
        if params[:id] && params[:id] != ''
          logger.debug "params[:id]: #{params[:id]}"
          serialized = sendApeNotification({ :debug_write_id=>params[:id]},session)
          
          render :text => serialized 
          return
        end


        comment = Comment.new( 
          :member_id => 1, :anonymous => "false", :status => "ok",
          :text => "re I want to be PM, 2nd immediate child",
          :created_at => Time.local(2010,7,7), :updated_at => Time.local(2010,7,7)
         )
        comment.id = 310;

        item = Item.new(
          :team_id => 10004, :o_id => 310, :o_type => 3, :ancestors => [0,724,737,747,789],
          :created_at => Time.new, :updated_at => Time.new)
        item.id = 1220
        item.par_id = 817
        item.sib_id = 1218
        item.order = 0
        item.target_id = 0
        item.target_type = 0
          
        resource = Resource.new(
          :comment_id => nil, :member_id => nil, :title => nil, :description => nil, :link_url => nil, 
          :resource_file_name => nil, :resource_file_size => nil, :resource_content_type => nil, 
          :created_at => Time.new, :updated_at => Time.new)
        resource.id = nil;


        serialized = sendApeNotification(
          {
            :type=>'com_json', 
            :channel=>"team#{10004}", 
            :debug_save_id=>item.id,
            :data => {
              :mode=>"add",
              :score=>1, :item_id=>item.id, :rated=>0, :count=>0, :up_score=>5, :down_score=>1,
              :par_id=>item.par_id, 
              :author=>"Brian%20Sullivan", 
              :pic_id=>10012,
              :resource_link=>nil, 
              :sib_id=>item.sib_id,
              :data=> comment, 
              :item=> item, 
              :resource=> resource
            }
          },session
            
        );

    
        render :text => serialized 
    
#        sendApeNotificationv1 params: {:type=>"com_json", :data=>{
#          :data=>#<Comment id: 310, member_id: 1, anonymous: false, status: "ok", text: "re I want to be PM, 2nd immediate child", created_at: "2010-07-09 20:53:39", updated_at: "2010-07-09 20:53:39">, 
#          :item=>#<Item id: 1220, team_id: 10004, o_id: 310, o_type: 3, par_id: 789, order: 1, created_at: "2010-07-09 20:54:23", updated_at: "2010-07-09 20:54:23", sib_id: 0, ancestors: "{0,724,737,747,789}", target_id: nil>, 
#          :par_id=>789, 
#          :author=>"Brian%20Sullivan", 
#          :resource_link=>nil, 
#          :sib_id=>0, 
#          :resource=>#<Resource id: nil, comment_id: nil, member_id: nil, title: nil, description: nil, link_url: nil, resource_file_name: nil, resource_file_size: nil, resource_content_type: nil, created_at: nil, updated_at: nil>, 
#          :mode=>"add"}, 
#          
#          :channel=>"team10004"}
#    
    
    
  end
  
  def delete_brainstorm_idea
    begin
      page_channel = 'page' + Item.find_by_o_id_and_o_type(params[:id],2).ancestors.match(/(\d+),(\d+),(\d+)/)[3]
      @answer = Answer.find(params[:id])
      @answer.destroy
    rescue EditAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'edit_access_denied'
      return
    end

    @deleteMode = @answer.itemDestroyed ? 'full' : 'partial'
    sendApeNotification({:type=>'bs_idea', :channel=>"team#{@answer.team_id}", :page_channel=>"#{page_channel}", 
    :data => {:item_type=>'Answer', :mode=>'delete_' + @deleteMode, :item_id=>@answer.item_id }},session);
    
    respond_to do |format|
      format.json { render :action => "delete_report" }
      format.html { redirect_to( :action => 'index' ) }
      format.xml  { head :ok }
    end
  end

  def summary
  end

  def stats
  end

  def admin
  end

  def members
  end
  
  def welcome
    
  end
  
  def inline_edit
    # handles posts from inline edit
    # look at type
    # data is in edited text
    
    logger.debug "inline_edit submission: #{params.inspect}"
   # # {} submission for type: #{params[:type]} with data: #{params[:edited_text]}"
   # 
    #format.html { render :action => "team/preview_invite_request", :layout => false } if request.xhr?

    #ProposalMailer.deliver_team_send_invite(member, recipient, @invite, team, request.env["HTTP_HOST"] )
    
    member = Member.find(session[:member_id])
    
    case params[:model]
      when 'team'
        model = Team.find( params[:id])
        model.member_id = session[:member_id]
        old_ver = model[params[:field]]
        new_ver = params[:edited_text].strip
        if old_ver != new_ver
          model[params[:field]] = new_ver
          saved = model.save
          if saved
            updated = true
            ProposalMailer.deliver_review_update(member, model, params[:field], old_ver, request.env["HTTP_HOST"], params[:_app_name] )
          end
        else
          saved = true # no errors to show
          updated = false
        end
        
      else
        logger.debug "Don't know how to handle model: #{params[:model]}"
        render :text=> 'Error - cannot handle request, we have been notified', :status=>500
    end
    
    if saved
      #format.html { render :action => "team/acknowledge_invite_request", :layout => false }      
      render :text=> params[:edited_text].strip
    else
    #  if !@invite.errors[:recipient_emails].nil? && @invite.errors[:recipient_emails].size() > 0 && request.xhr?
      render :text => [model.errors].to_json, :status => 409
    end
    
  end
  
protected

  def get_target(target_item)
    logger.debug "target_item.o_type: #{target_item.o_type}"
        logger.debug "target_item.o_id: #{target_item.o_id}"
    case target_item.o_type
      when 1
        @target = Question.find_by_id(target_item.o_id)
      when 2
        @target = Answer.find_by_id(target_item.o_id)
      when 3
        @target = Comment.find_by_id(target_item.o_id)
      when 4
        @target = Team.find_by_id(target_item.o_id)
      when 5
        @target = ChatSession.find_by_id(target_item.o_id)
      when 7
        @target = List.find_by_id(target_item.o_id)
      when 9
        @target = Page.find_by_id(target_item.o_id)

    end
    #logger.debug "return target: #{@target.inspect}"
    #logger.debug "target comment is #{@target.text}"
    @target
  end  
  

end
