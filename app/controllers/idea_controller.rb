class IdeaController < ApplicationController
  include LibCe
  
  def index
    @team_id = params[:id].to_i
    @team = Team.find_by_id(@team_id, :limit=>1)
    
    if @team.nil?
      render :template => 'team/proposal_not_found', :layout=>'welcome'
      return
    end

    #@num_mems = TeamRegistration.count(:conditions => ['team_id = ?', @team_id])
    #@num_comments = Comment.count(:conditions => ['team_id = ?', @team_id])
    #@num_ideas = BsIdea.count(:conditions => ['team_id = ?', @team_id])
    #@num_ans = Answer.count(:conditions => ['team_id = ?', @team_id])
    #
    #@last_ts = Team.find(@team_id).last_visit( @member_id )
    # get the page, question and answer items
    @items = @team.items.find(:all, :conditions => 'o_type IN (1,2,9)')
    @questions = @team.questions
    @answers_with_ratings = @team.answers_with_ratings( @member.id )
    
    
    
  end

  def bsd
    # start with question id
    # get the question
    @question = Question.find(params[:id])
    # after_find gets the question's item_id and the team_id
    
    team_init_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = #{@question.team_id}")
    restrictions_test,message = InitiativeRestriction.allow_action(team_init_id, 'view_question_details', @member)
    
    if !restrictions_test
      #logger.warn "failed restrictons test with message: #{message}"
      @error = "Sorry, this is a protected page"
    else
      # collect the bs_ideas with rating and the comments with ratings and display page
      @bs_ideas = @question.bs_ideas_with_favorites(@member.id)
      @comments, @resources, @authors = @question.comments_with_ratings(@member.id)
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
    
    team_init_id = ActiveRecord::Base.connection.select_value( "SELECT initiative_id FROM teams WHERE id = #{@question.team_id}")
    restrictions_test,message = InitiativeRestriction.allow_action(team_init_id, 'view_question_details', @member)
    
    if !restrictions_test
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
      #@bs_idea.par_id = @bs_idea.question_id
   
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
  


  def get_templates

    @team = Team.new(:com_criteria=>'4..7', :res_criteria=>'3..8')
    strs = []
    strs.push '<div>'
    item = Item.new(:target_id => 1, :target_type => 11)
    # @members = [ ]
    # @items = [ ]
    # @last_ts = Time.now
    old_ts = Time.local(2020,1,1)
    newer_ts = Time.local(2025,1,1)
    #  
    # strs.push '<hr/><h3>Question w/ answer and idea</h3><hr/>'
    # bs_idea_rating = BsIdeaRating.new(:member_id => session[:member_id], :created_at => old_ts, :updated_at => newer_ts)
    # bs_idea_rating[:q_id] = 1
    # bs_idea_rating[:my_vote] = 3
    # bs_idea_rating[:text] = 'Idea for the template'
    # bs_idea_rating[:average] = 4.5
    # bs_idea_rating[:count] = 7
    # @bs_ideas_with_ratings = [ bs_idea_rating ] 
    # 
    # answer_rating = AnswerRating.new(:created_at => old_ts, :updated_at => old_ts)
    # answer_rating[:q_id] = 1
    # answer_rating[:my_vote] = 2
    # answer_rating[:text] = 'answer for the template'
    # answer_rating[:ver] = 2
    # answer_rating[:average] = 4.5
    # answer_rating[:count] = 7
    # @answers_with_ratings = [answer_rating]

    @question = Question.new(:text => 'Question for template', :created_at => old_ts, :updated_at => old_ts, :answer_criteria=>'5..15',:idea_criteria=>'6..12')
    @question.id = 1
    #
    #strs.push '<div class="item Question">'
    #strs.push render_to_string( :partial => '/team/question', :object => question,
    # :locals => { :item => item} )
    #strs.push '</div>'

    strs.push '<hr/><h3>comment</h3><hr/>'
    @comment = Comment.new(:created_at => old_ts, :updated_at => newer_ts)
           
    @comment[:anonymous] = 'f'
    @comment[:member_id] = session[:member_id]
    @comment[:pic_id] = 10011
    @comment[:text] = ''
    @comment[:my_vote] = 0
    @comment[:up] = 0
    @comment[:down] = 0
    @comment[:par_id] = 0
    @comment[:sib_id] = 123
    @comment[:item_id] = 123
    @comment.member_id = 1
    @resources = [ Resource.new ] 
    @authors = [Member.new :first_name=>'J', :last_name=>'Public' ]
    @authors[0].id = 1
    @comments = []

    
    strs.push '<div class="item Comment">'
    strs.push render_to_string( :partial => 'comment', :object => @comment,
      :locals => { :item => item, :down => 0, :up => 0,  :rated => 0})
    strs.push '</div>'


    strs.push '<hr/><h3>add_comment_combined</h3><hr/>'
    strs.push render_to_string(:partial => 'add_comment_combined', :locals => { :id => 1, :label=>'Please add your comment'})
    strs.push '<hr/><h3>add_answer</h3><hr/>'
    strs.push render_to_string(:partial => 'add_answer', :locals => { :question=>@question })
    strs.push '<hr/><h3>add_bs_idea</h3><hr/>'
    strs.push render_to_string(:partial => 'add_bs_idea', :locals => { :question=>@question })

    bs_idea = BsIdeaRating.new(:member_id => session[:member_id], :created_at => old_ts, :updated_at => newer_ts)
    bs_idea[:item_id] = 1
    strs.push '<hr/><h3>bs_idea</h3><hr/>'
    strs.push render_to_string( :partial=> 'bs_idea', :object=>bs_idea, :locals=>{:mode=>'new', :coms=>'t'} )

    #strs.push '<hr/><h3>chat message</h3><hr/>'
    #strs.push render_to_string(:partial => '/team/chat')

    strs.push '</div>'
    render :text => strs.join('') #, :content_type => 'text/xml'
    
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

end
