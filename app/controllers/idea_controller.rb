require 'recaptcha'
class IdeaController < ApplicationController
  include ReCaptcha::AppHelper
  include LibCe
  
  def index
    @team_id = params[:id].to_i
    @team = Team.find_by_id(@team_id, :limit=>1)

    if @team.nil?
      render :template => 'team/proposal_not_found', :layout=>'welcome'
      return
    end
    
    
    # verify acccess to this team
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
    
    #@num_mems = TeamRegistration.count(:conditions => ['team_id = ?', @team_id])
    #@num_comments = Comment.count(:conditions => ['team_id = ?', @team_id])
    #@num_ideas = BsIdea.count(:conditions => ['team_id = ?', @team_id])
    #@num_ans = Answer.count(:conditions => ['team_id = ?', @team_id])
    #
    #@last_ts = Team.find(@team_id).last_visit( @member_id )
    # get the page, question and answer items
    @items = @team.items.find(:all, :conditions => 'o_type IN (1,2,9)')

    @questions = @team.questions.reject{|q| q.default_answer_id.nil?}
    def_ans_ids = @questions.map{|q| q.default_answer_id} #.reject{|i| i.nil?}

    #@default_answers = DefaultAnswer.find(def_ans_ids)
    @default_answers = DefaultAnswer.where("id IN (?)",def_ans_ids)
    @answers_with_ratings = @team.answers_with_ratings_i( @member.id )

    # remove answer_items for testing
    #@items = @items.find_all{|i| i.o_type != 2 }
    
    #@mems = Member.all( :conditions=>['id IN (SELECT distinct member_id FROM comments WHERE team_id = ?)',@team.id]);

    @mems = Member.all( :conditions=>[%q|id IN (SELECT distinct member_id FROM comments WHERE team_id = ?
      UNION
      SELECT distinct member_id FROM bs_ideas WHERE team_id = ?
      UNION
      SELECT org_id FROM teams WHERE id = ?)|,@team.id,@team.id, @team.id]);
    
  	@endorsements = Endorsement.all(:conditions=>['team_id=?',@team.id])
  	@endorsers = Member.all(:conditions=> {:id => @endorsements.map{|e| e.member_id }.uniq })
    
    
  end

  def bsd
    # start with question id
    # get the question
    @question = Question.find(params[:id])
    # after_find gets the question's item_id and the team_id
    
    allowed,message = InitiativeRestriction.allow_action({:team_id=>@question.team_id}, 'view_question_details', @member)
    
    if !allowed
      #logger.warn "failed restrictons test with message: #{message}"
      @error = "Sorry, this is a protected page"
    else
      # collect the bs_ideas with rating and the comments with ratings and display page
      # but exclude ideas that are not published and don't belong to this author
      @bs_ideas,priorities = @question.bs_ideas_with_favorites(@member.id)
      @bs_ideas.reject!{|bsi| bsi.publish == false || !bsi.publish && bsi.member_id != @member.id}
      
      
      @priority = priorities.nil? ? [] : priorities.priority.scan(/\d+/).collect{|p| p.to_i }
      @comments, @resources, @authors = @question.comments_with_ratings(@member.id)
      # get the public discussion node and process the public comments so they are part of the unified discussion
      pub_item = Item.find_by_sql(["SELECT * FROM items WHERE o_type = 11 and par_id in (SELECT id FROM items WHERE o_type = 1 and o_id = ?)",@question.id])[0]
      # but exclude comments that are not published and don't belong to this author      
      @comments.reject!{|c| c.publish == false || c.publish.nil? && ( c.member_id != @member.id && c.status != 'prereview' ) }
      @comments.each{|c| c['par_id'] = pub_item.par_id.to_s if c['par_id'].to_i == pub_item.id} unless pub_item.nil?
      @new_coms = @coms = 0
      @mode = request.xhr? ? 'insert' : 'page'

      if @mode == 'insert'
        render :action => "bsd", :layout => false
      else
        @answers = @question.answers_with_ratings(@member.id)  
      end
      
    end
    
  end

  def bs_idea_comment 
    # start with idea id
    # get the ide
    @bs_idea = BsIdea.find(params[:id])
    # get the question
    @question = Question.find(@bs_idea.question_id)
    # after_find gets the question's item_id and the team_id
    
    allowed,message = InitiativeRestriction.allow_action({:team_id=>@question.team_id}, 'view_question_details', @member)
    
    if !allowed
      #logger.warn "failed restrictons test with message: #{message}"
      @error = "Sorry, this is a protected page"
    else
      # collect the comments with ratings and display page
      @comments, @resources, @authors = @bs_idea.comments_with_ratings(@member.id)
      @answers = @question.answers_with_ratings(@member.id)      
      
    end
    
  end


  def endorse
  end

  def submit
  end

  def reply
    params[:mode] ||= 'add' 
    @target_item = Item.find(params[:id]) unless @target_item
    @target = get_target(@target_item)
    #logger.debug "target is #{@target.inspect}"
    # get a new comment object for the view
    @comment = Comment.new(params[:comment]) unless @comment
    @resource = Resource.new(params[:resource]) unless @resource
    logger.debug "options = #{params[:option]}"
    respond_to do |format|
      format.html { render :action => "add_comment_with_upload" } if params[:option] =~ /upload/
      format.html { render :action => "add_comment_with_link" } if params[:option] =~ /link/
      format.html { render :action => "add_comment" } if params[:option] =~ /simple/ || params[:option].nil?
      format.html # new.html.erb
      format.xml  { render :xml => @answer }
    end
  end
  
  
  def create_comment
    logger.debug "create_comment mode: #{params[:mode]}"
    logger.debug "Check if the user wants to add a link or upload a file option: #{params[:option]}"
    #debugger
    # check if user wants to link or upload, if so, call back to add_comment
    if params[:option] 
      params[:id] = params[:par_id]
      logger.debug "call add_comment with params[:option]: #{params[:option]}"
      add_comment
      reply # this will reload the desired form for a resource upload or link
    end

    save_com = true
    if params[:mode] == 'add'
      logger.debug ":mode == 'add'"
      # create comment and add par_id and member_id
      @comment = Comment.new(params[:comment])
      @comment.par_id = params[:par_id]
    
      @comment.member_id = @member.id
      @comment.insert_mode = params[:insert_mode]
      @comment.member = @member
    else
      logger.debug "!add, :mode is #{params[:mode]}"
      @comment = Comment.find(params[:id])
      
      # I need to make sure this comment belongs to user
      if @comment.member_id != @member.id
        @comment.errors.add_to_base("You cannot edit this comment.")
        logger.warn "user #{@member.id} tried to edit comment id: #{params[:id]}"
        save_com = false
        @saved = false
      else
        @comment.attributes = params[:comment]
        @comment.member = @member
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
              @resource.member_id = @member.id
              @resource.resource_type = params[:resource_type]
            else
              @resource = @comment.resource
              logger.debug "Determine if I need to destroy the old resource: #{@resource}"
              # if I am changing the type of resource away from upload file,
              # destroy the record to eliminate the downloaded file
              if !@resource || (params[:resource_type] == 'link' && @resource.resource_file_name) || (params[:resource_type] == 'upload' && @resource.link_url)
                @resource.destroy() unless !@resource
                @resource = Resource.new(params[:resource])
                @resource.member_id = @member.id
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
        @members = [ @member ]
        
        author = escape_json_text( @comment.anonymous ? 'Anonymous' : (@member.nil? ? 'Unknown author' : @member.first_name + ' ' + @member.last_name) )
        ape_code = @comment.anonymous ? '' : @member.ape_code
        author_url = @comment.anonymous ? '/images/members_default/36/m.jpg' : (@member.nil? ? '/images/members_default/36/m.jpg' : @member.photo.url('36')) 
       # time_ago = escape_json_text( time_ago_in_words(@comment.created_at) + ' ago' )
        #debugger

        res_link = render_to_string :partial => 'comment_resource_link' if !@resource.nil?
        
        # get the score data: up, down, my_vote
        if params[:mode] != 'add'
          rating = ComRating.com_ratings(@comment.id,@member.id)[0]
          up = rating.nil? ? 0 : rating.up
          down = rating.nil? ? 0 : rating.down
          my_vote = rating.nil? ? 0 : rating.my_vote
        else
          up = down = my_vote = 0
        end

        # send JSON data to ape, it will be converted to js
        serialized = sendApeNotification({:type=>'com_json', :channel=>"team#{@comment.team_id}", :debug_save_id => item.id,
          :data => {:mode=>params[:mode], :item_id=>item.id, :par_id=>item.par_id, :sib_id=>item.sib_id, :item => item, :author => author, :ape_code=> ape_code, 
          :pic_url=> author_url, :data => @comment, :resource => @resources[0], :resource_link => res_link, :up => up, :down => down,
          :my_vote => my_vote }},session);

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
  
  
  def create_brainstorm_idea
    logger.debug "create the brainstorm_idea"
    
    begin
      if params[:mode] == 'add'
        # create answer and add par_id and member_id
        @bs_idea = BsIdea.new
        @bs_idea.member_id = @member.id
      else
        @bs_idea = BsIdea.find( params[:idea_id] )
      end
      @bs_idea.attributes = params[:bs_idea]
      @bs_idea.member = @member
      #@bs_idea.par_id = @bs_idea.question_id
   
      logger.debug "try to save the brainstorm_idea"
      
      @saved = @bs_idea.save  # in place of saved for testing
      
    rescue TeamAccessDeniedError
      logger.debug "TeamAccessDeniedError error"
      redirect_to :action => 'access_denied'
      return
    end

    ajaxMode = request.xhr? || params[:post_mode] == 'ajax'

    # render a response
    respond_to do |format|
      if @saved
        BsIdeaFavorite.new( :member_id => @member.id, :bs_idea_id => @bs_idea.id, :favorite => true ).save
        
        if params[:mode] != 'add'
          logger.debug "Get the score data for this answer which is being edited"
          rating = BsIdeaRating.idea_ratings(@bs_idea.id,@member.id)[0]
          average = rating.nil? ? 0 : rating.average
          count = rating.nil? ? 0 : rating.count
          my_vote = rating.nil? ? 0 : rating.my_vote
        else
          average = count = my_vote = 0
        end
        
        logger.debug "idea was saved successfully"
        flash[:notice] = 'Idea was successfully created.'
        
       # I need to provide these items to generate html for APE
        item = Item.find_by_o_id_and_o_type(@bs_idea.id,@bs_idea.o_type)

        # send JSON data to ape, it will be converted to js
        serialized = sendApeNotification({:type=>'bs_idea', :channel=>"team#{@bs_idea.team_id}", :debug_save_id => item.id,
          :data => {:mode=>params[:mode], :data => @bs_idea, :item_id=>item.id, :par_id=>item.par_id, :sib_id=>item.sib_id, :item => item, 
          :average => average, :count => count, :my_vote => my_vote}},session);
          
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
  
  def com_rate
    com_id = params[:thumbsup_id]
    rating = params[:thumbsup_rating]

    #logger.debug "com_rate member: #{@member.id}, com_id: #{com_id}, rating: #{rating}"
    
    com_rating = ComRating.find_by_comment_id_and_member_id(com_id, @member.id) 
    if com_rating.nil?
      com_rating = ComRating.new :member_id => @member.id, :comment_id => com_id, :up => rating.to_i > 0 ? 1 : 0, :down => rating.to_i > 0 ? 0 : 1
    else
      com_rating.up = rating.to_i > 0 ? 1 : 0
      com_rating.down = rating.to_i > 0 ? 0 : 1
    end
    com_rating.member = @member
    saved = com_rating.save

    if saved
      #calculate new score, count and average
      @up = ComRating.sum(:up, :conditions => ['comment_id = ?', com_id ])
      @down = ComRating.sum(:down, :conditions => ['comment_id = ?', com_id ])
    
      serialized = sendApeNotification({:type=>'com_rate', :channel=>"team#{com_rating.team_id}", :data => {:up=>@up, :down=>@down, :com_id=>com_id, :my_vote => rating }},session);

      respond_to do |format|
        format.html { render :text => serialized } if request.xhr? # ajaxmode gets the update via APE    
        #format.html { request.referer ?  redirect_to(request.referer + "\#item_rater_#{@item_id}") :  redirect_to( :action => 'index' ) }
      end
    else
      # what to return if error?
      logger.debug "com_rate was not saved "
      if request.xhr?
        respond_to do |format|
          format.json { render :text => [com_rating.errors].to_json, :status => 409 }
          #combine the errors from resources into comment errors so they will all be displayed
          #format.html {render :partial => 'team/error', :object => @comment, :status => 400, :locals => { :resources => @resources} }
        end
      end
    end
  end
  
  def answer_rating
    logger.debug "answer_rating: #{params.inspect}"
    name = params.keys.grep(/bs_rating/)[0]
    # what if name is nil?
    score = params[name]

    @answer_id = name.match(/(\d+)/)[1]
    logger.debug "save answer_rating :member_id: #{@member.id}, :answer_id => #{@answer_id}, :score => #{score}"
    rating = AnswerRating.find_by_answer_id_and_member_id(@answer_id, @member.id) 

    if rating.nil?
      rating = AnswerRating.new :member_id => @member.id, :answer_id => @answer_id, :rating => score
    else
      rating.rating = score
    end
    rating.member = @member
    saved = rating.save
    if saved
      #calculate new score, count and average
      @average = AnswerRating.average(:rating, :conditions => ['answer_id = ?', @answer_id ])
      @count = AnswerRating.count(:rating, :conditions => ['answer_id = ?', @answer_id ])

      serialized = sendApeNotification({:type=>'rating', :channel=>"team#{rating.team_id}", :data => {:type => 'answer', :average=>@average, :count=>@count, :id=>@answer_id }},session);

      respond_to do |format|
        format.html { render :text => serialized } if request.xhr? # ajaxmode gets the update via APE
        #format.js
        format.html { request.referer ?  redirect_to(request.referer + "\#item_rater_#{@item_id}") :  redirect_to( :action => 'index' ) }
      end
    else
      # what to return if error?
      logger.debug "answer rating was not saved "
      if request.xhr?
        respond_to do |format|
          format.json { render :text => [rating.errors].to_json, :status => 409 }
          #combine the errors from resources into comment errors so they will all be displayed
          #format.html {render :partial => 'team/error', :object => @comment, :status => 400, :locals => { :resources => @resources} }
        end
      end
      
    end
  end  

  def bs_idea_favorite
    member_id = @member.id
    bs_idea_id = params[:thumbsup_id]
    favorite = params[:thumbsup_favorite].to_i > 0 ? true : false

    logger.debug "bs_idea_favorite member: #{member_id}, bs_idea_id: #{bs_idea_id}, favorite: #{favorite}"

    bs_idea_favorite = BsIdeaFavorite.find_by_bs_idea_id_and_member_id(bs_idea_id, member_id) 
    if bs_idea_favorite.nil?
      bs_idea_favorite = BsIdeaFavorite.new :member_id => member_id, :bs_idea_id => bs_idea_id, :favorite => favorite 
    else
      bs_idea_favorite.favorite = favorite
    end
    bs_idea_favorite.member = @member
    saved = bs_idea_favorite.save

    if saved
      #calculate new score, count and average
      #@up = BsIdeaFavorite.sum(:up, :conditions => ['comment_id = ?', bs_idea_id ])
      #@down = BsIdeaFavorite.sum(:down, :conditions => ['comment_id = ?', bs_idea_id ])
    
      serialized = sendApeNotification({:type=>'com_rate', :channel=>"team#{bs_idea_favorite.team_id}", :data => { :bs_idea_id=>bs_idea_id, :favorite => favorite }},session);

      respond_to do |format|
        format.html { render :text => serialized } if request.xhr? # ajaxmode gets the update via APE    
        #format.html { request.referer ?  redirect_to(request.referer + "\#item_rater_#{@item_id}") :  redirect_to( :action => 'index' ) }
      end
    else
      # what to return if error?
      logger.debug "bs_idea_favorite was not saved "
      if request.xhr?
        respond_to do |format|
          format.json { render :text => [bs_idea_favorite.errors].to_json, :status => 409 }
          #combine the errors from resources into comment errors so they will all be displayed
          #format.html {render :partial => 'team/error', :object => @comment, :status => 400, :locals => { :resources => @resources} }
        end
      end
    end
  end

  def create_answer
    logger.debug "create the answer"
    
    begin
      if params[:mode] == 'add'
        # create answer and add par_id and member_id
        @answer = Answer.new
        @answer.par_id = params[:par_id]
        @answer.member_id = @member.id
      else
        @answer = Answer.find(params[:id])
      end
      # store initial values so the revision history will work
      @answer.store_initial_values  
      @answer.attributes = params[:answer]
      @answer.member_id = @member.id
      @answer.member = @member
   
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
        @members = [ @member ]

        if params[:mode] != 'add'
          logger.debug "Get the score data for this answer which is being edited"
          rating = AnswerRating.answer_ratings(@answer.id,@member.id)[0]
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





  def update_fav_bs_idea_order
    logger.debug "update_fav_bs_idea_order for question_id: #{params[:question_id]}, order: #{params[:ids]}"
 
    ids = '{' + params[:ids].join(',') + '}'
    ideas_priority = BsIdeaFavoritePriority.find_by_member_id_and_question_id(@member.id, params[:question_id]) 
    if ideas_priority.nil?
      ideas_priority = BsIdeaFavoritePriority.new :member_id => @member.id, :question_id => params[:question_id], :priority => ids
    else
      ideas_priority.priority = ids
    end
    ideas_priority.member = @member
    saved = ideas_priority.save
    respond_to do |format|
      format.json { render :text => ['ok'].to_json }
    end
  end


  def endorse_proposal
    logger.debug "endorse_proposal for question_id: #{params[:question_id]}, order: #{params[:ids]}"
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id, params[:team_id]) 
    if params[:act] == 'delete'
      endorsement.destroy
      # create a new endorsment object so I can send ape message
      endorsement = Endorsement.new :member_id => @member.id, :team_id => params[:team_id], :text => ''
      saved = true
    elsif endorsement.nil?
      endorsement = Endorsement.new :member_id => @member.id, :team_id => params[:team_id], :text => params[:endorse][:text], :member=>@member
      saved = endorsement.save
      pic_url = @member.photo.url('36')
    else
      endorsement.text = params[:endorse][:text]
      endorsement.member = @member
      saved = endorsement.save
      pic_url = @member.photo.url('36')
    end
    mem_name = @member.first_name + '%20' + @member.last_name
    ajaxMode = request.xhr? || params[:post_mode] == 'ajax'
    # render a response
    respond_to do |format|
      if saved
        logger.debug "endorse_proposal was saved successfully"
        #flash[:notice] = 'Idea was successfully created.'
        # send JSON data to ape, it will be converted to js
        serialized = sendApeNotification({:type=>'endorsment', :channel=>"team#{params[:team_id]}", :debug_save_id => 'endorsement',
          :data => {:mode=>params[:mode], :data => endorsement, :name => mem_name, :ape_code=> @member.ape_code,  :pic_url => pic_url || '' }},session);
          
        format.html { render :text => serialized } if request.xhr?
        format.html { redirect_to( :action => 'index' ) }
        #format.xml  { render :xml => @answer, :status => :created, :location => @answer }
      else
        # serialize the form errors and send back ajson
        
        if ajaxMode
          format.json { render :text => [endorsement.errors].to_json, :status => 409 }
        else
          # this code generates a static page with the target of the comment, the comment form, and the error data - for now I just want the error data
          #@target_item = Item.find(params[:par_id])
          #@target = get_target(@target_item)
          #format.html { render :action => "add_answer" }
        end
      end
    end
    
  end
  
  def guidelines
    render :action => "guidelines", :layout => false 
  end
  
  def tooltips
    render :action => "tooltips", :layout => false 
  end
  
  def request_help
    render :action => "request_help", :layout => false 
  end
  
  def request_help_post
    
    team_id = params[:url] && params[:url].match(/\d+$/) ? params[:url].match(/\d+$/)[0] : nil
    # create the client_details
    client_details = ClientDetails.new :ip=> request.remote_ip, :session_id=> request.session_options[:id], :member_id=> session[:member_id], 
      :team_id=> team_id, :url=> params[:url], :user_agent=> params[:user_agent], :error_log=> params[:error_log]
    @saved = client_details.save
    
    if @saved
      @help_request = HelpRequest.new params[:request_help]
      @help_request.client_details_id = client_details.id
      @saved = @help_request.save
    end
    
    if @saved
      case @help_request.category
      	when 1
      	  @help_request['type'] = 'Report a bug'
      	when 2
      	  @help_request['type'] = 'I need help to use CivicEvolution'
      	when 3
      	  @help_request['type'] = 'I need assistance with my proposal'
      	when 4
      	  @help_request['type'] = 'I need help dealing with my fellow participants'
      	when 5
      	  @help_request['type'] = 'I need technical assistance with my proposal'
      	when 6
      	  @help_request['type'] = 'I have a suggestion'
      end
      
      #member = Member.find(session[:member_id])
      HelpMailer.deliver_help_request_review(@member, @help_request, client_details, request.env['HTTP_HOST'], params[:_app_name])
      begin
        HelpMailer.deliver_help_request_receipt(@member, @help_request, client_details )
      rescue
        @mail_error = true
      end
      
    end
    
    respond_to do |format|
      if @saved
        format.html { render :action => "acknowledge_request_help", :layout => false } if request.xhr?
      else
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end
    
  end
  
  
  def get_templates
    
    @team = Team.new(:com_criteria=>'4..7', :res_criteria=>'3..8')
    strs = []
    strs.push '<div>'
    old_ts = Time.local(2020,1,1)
    newer_ts = Time.local(2025,1,1)

    @question = Question.new(:text => 'Question for template', :created_at => old_ts, :updated_at => old_ts, :answer_criteria=>'5..15',:idea_criteria=>'6..12')
    @question.id = 1

    strs.push '<hr/><h3>comment</h3><hr/>'
    @comment = Comment.new(:created_at => old_ts, :updated_at => newer_ts)
           
    @comment[:anonymous] = 'f'
    @comment.publish = true
    @comment[:member_id] = @member.id
    @comment[:pic_id] = 10011
    @comment[:text] = ''
    @comment[:my_vote] = 0
    @comment[:up] = 0
    @comment[:down] = 0
    @comment[:par_id] = 0
    @comment[:sib_id] = 123
    @comment[:item_id] = 123
    @comment.member_id = 0
    @resources = [ Resource.new ] 
    @authors = [Member.new(:first_name=>'J', :last_name=>'Public') ]
    @authors[0].id = 0
    @comments = []
    @new_coms = @coms = 0
    @member = Member.new
    @member.id = 0
    
    strs.push render_to_string( :partial => 'comment', :object => @comment,
      :locals => { :item => Item.new, :down => 0, :up => 0,  :rated => 0, :mode=>'templ'})

    strs.push '<hr/><h3>add_comment_combined</h3><hr/>'
    strs.push render_to_string(:partial => 'add_comment_combined', :locals => { :id => 1, :label=>'Please add your comment'})
    strs.push '<hr/><h3>add_answer</h3><hr/>'
    strs.push render_to_string(:partial => 'add_answer', :locals => { :question=>@question })
    strs.push '<hr/><h3>add_bs_idea</h3><hr/>'
    strs.push render_to_string(:partial => 'add_bs_idea', :locals => { :question=>@question })

    bs_idea = BsIdea.new(:member_id => @member.id, :created_at => old_ts, :updated_at => newer_ts)
    bs_idea.item_id = 1
    strs.push '<hr/><h3>bs_idea</h3><hr/>'
    strs.push render_to_string( :partial=> 'bs_idea', :object=>bs_idea, :locals=>{:mode=>'templ', :coms=>'t'} )
 
    answer = Answer.new :text=>'', :ver=>1, :item_id=>0
		answer['my_vote'] = answer['average'] = answer['count'] = 3
    strs.push '<hr/><h3>answer</h3><hr/>'
    strs.push render_to_string( :partial => 'answer', :object=>answer, :locals=> {:question=> @question, :title=>'Current answer', :def_ans=>nil, :is_def_ans=>false} )
    

    #strs.push '<hr/><h3>chat message</h3><hr/>'
    #strs.push render_to_string(:partial => '/team/chat')
    
    @endorsements = [Endorsement.new(:member_id=>1, :updated_at=> old_ts)]
    @member = Member.find(1)
  	@endorsers = [ @member ]
    strs.push '<hr/><h3>endorsement</h3><hr/>'
    strs.push render_to_string( :partial=> 'endorsements')

    strs.push '</div>'
    render :text => strs.join('') #, :content_type => 'text/xml'
    
  end
  
  def report
    item = Item.find(params[:id])
    case item.o_type
      when 2 #answer
        @text = Answer.find(item.o_id).text
      when 3 # comment
        @text = Comment.find(item.o_id).text
      when 12 # bs_idea
        @text = BsIdea.find(item.o_id).text
    end
    @text += "..." if @text.slice!(200 .. -1)
    
    render :action=> 'report', :layout=>false
    
  end
  
  def post_content_report
    
    @report = ContentReport.new params[:content_report]
    @report.member_id = @member.id unless @member.nil?
    @saved = @report.save
    
    if @saved
      if @member
        @report.sender_name = @member.first_name + ' ' + @member.last_name
        @report.sender_email = @member.email
      end
      
      item = Item.find(@report.item_id)
      case item.o_type
        when 2 #answer
          @text = Answer.find(item.o_id).text
        when 3 # comment
          @text = Comment.find(item.o_id).text
        when 12 # bs_idea
          @text = BsIdea.find(item.o_id).text
      end

      AdminReportMailer.deliver_report_content(@report, @text, item, request.env['HTTP_HOST'],params[:_app_name] )
    end

    respond_to do |format|
      if @saved
        format.html { render :text => "Thank you for reporting this content. We will review it soon.", :layout => false } if request.xhr?
      else
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end

  end

  def submit_proposal
    @team = Team.find(params[:id])
    
    # params[:act]  = pre_review | submit
    # params[:step] = post | nil
    if params[:step].nil?
      render :action=> 'submit_proposal', :layout=> false
      return
      
    else
      submit_request = ProposalSubmit.new params[:proposal_submit]
      submit_request.member = @member
      submit_request.member_id = @member.id
      logger.debug "review submit_request: #{submit_request.inspect}"
      @saved = submit_request.save
      
      respond_to do |format|
        if @saved
          AdminReportMailer.deliver_submit_proposal(submit_request, @team, @member, request.env['HTTP_HOST'],params[:_app_name] )
          format.html { render :action=> 'submit_proposal_acknowledge', :layout=>false } if request.xhr?
        else
          format.json { render :text => [submit_request.errors].to_json, :status => 409 }
        end
      end
      
      return
    end

  end

  def release_comments
    case params[:act]
      when /preferences/
        logger.debug "release_comments Save preferences"
        params.each_pair do |key,val| 
          mat = /^com(\d+)$/.match(key)
          if !mat.nil?
            id = mat[1].to_i
            pub = val == 't' ? true : false
            #puts "set com #{id} to #{val}"
            ActiveRecord::Base.connection.update_sql("UPDATE comments SET publish = #{pub} where id = #{id}");
          end
        end
      when /public/
        logger.debug "release_comments Publish all"
        ActiveRecord::Base.connection.update_sql("UPDATE comments SET publish = true where member_id = #{@member.id}");
      else
    end
    @comments = Comment.all( :conditions=>"member_id = #{@member.id} AND team_id > 10017 AND publish is NULL", :order=>'created_at');
    
    render :action=>'release_comments', :layout=>'welcome'
    
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
    
    case params[:model]
      when 'team'
        model = Team.find( params[:id])
        model.member_id = @member.id
        old_ver = model[params[:field]]
        new_ver = params[:edited_text].strip
        if old_ver != new_ver
          model[params[:field]] = new_ver
          saved = model.save
          if saved
            updated = true
            ProposalMailer.deliver_review_update(@member, model, params[:field], old_ver, request.env["HTTP_HOST"], params[:_app_name] )
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
  
  def invite
    @host = request.env["HTTP_HOST"]
    render :action=> 'invite', :layout=>false
  end
  
  def invite_friends
    logger.debug "invite_friends #{params.inspect}"
    
    team = Team.find(params[:team_id])
    
    @invite = InviteEmail.new :sender => @member, :recipient_emails => params[:recipient_emails], :message=> params[:message]
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
          @email = ProposalMailer.create_team_send_invite(@member, recipient, @invite, team, request.env["HTTP_HOST"] )
          format.html { render :action => "team/preview_invite_request", :layout => false } if request.xhr?
          format.html { render :action => "team/preview_invite_request", :layout => 'welcome' }
        else
          @invite.recipients.each do |recipient|
            logger.debug "Send an email to #{recipient[:first_name]} at #{recipient[:email]}"
            ProposalMailer.deliver_team_send_invite(@member, recipient, @invite, team, request.env["HTTP_HOST"] )
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
  
  protected

  def get_target(target_item)
    #logger.debug "target_item.o_type: #{target_item.o_type}"
    #logger.debug "target_item.o_id: #{target_item.o_id}"
    case target_item.o_type
      when 1
        @target = Question.find_by_id(target_item.o_id)
        @target['question_id'] = target.id
      when 2
        @target = Answer.find_by_id(target_item.o_id)
      when 3
        @target = Comment.find_by_id(target_item.o_id)
        @target['question_id'] = ActiveRecord::Base.connection.select_value(
          "SELECT o_id FROM items WHERE o_type = 1 AND id = ANY (( SELECT ancestors FROM items WHERE o_id=#{id} and o_type = 3)::INT[])")
      when 4
        @target = Team.find_by_id(target_item.o_id)
      when 5
        @target = ChatSession.find_by_id(target_item.o_id)
      when 7
        @target = List.find_by_id(target_item.o_id)
      when 9
        @target = Page.find_by_id(target_item.o_id)
      when 12
        @target = BsIdea.find_by_id(target_item.o_id)
    end
    #logger.debug "return target: #{@target.inspect}"
    #logger.debug "target comment is #{@target.text}"
    @target
  end  
  
  IDEA_CONTROLLER_PUBLIC_METHODS = ['index', 'bsd', 'guidelines', 'get_templates', 'report', 'post_content_report', 'request_help', 'request_help_post', 'tooltips','invite']
  
  def authorize
    #debugger
    unless IDEA_CONTROLLER_PUBLIC_METHODS.include? request[:action]
      # do this except for public methods
      if (@member.nil? || @member.id == 0 ) && request.xhr?
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
      end
    end
    if @member.nil? 
      @member = Member.new :first_name=>'Unknown', :last_name=>'Visitor'
      @member.id = 0
      @member.email = ''
    end
  end
  
end
