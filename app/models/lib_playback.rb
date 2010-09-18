# move this to library when it is stable
# /lib is not reloaded in dev, but putting this module in models means it will be reloaded each time it is referenced
module LibPlayback

  def get_play_back_data(params)
    logger.debug "get_play_back_data for id: #{params[:id]}"
    
    # convert ts into a timestamp or use the default
    begin
      ts = DateTime.strptime(str=params[:ts], fmt='%m%d%Y%H%M%Z')
    rescue
      ts = DateTime.now().new_offset(of=0) - 2
    end
    # /playback/get_playback?id=10000&type=team&scope=12&ts=022120091200
    # ts = params[:ts].match(/(\d\d)(\d\d)(\d\d\d\d):(\d\d)(\d\d)/)
    # ts = "#{ts[1]}-#{ts[2]}-#{ts[3]} #{ts[4]}:#{ts[5]}"
    # params = {:ts=>'022120101230'}
    # DateTime.strptime(str=params[:ts], fmt='%m%d%Y%H%M')
    # Sun, 21 Feb 2010 12:30:00 +0000
    
    logger.debug "params[:ts]: #{params[:ts]}, ts: #{ts.to_s} "

# there are different ways to request data
# team  id, [ts] [scope=all]
# item  id, [ts] [scope=all]
# children id gets partial for dynamic playback
# parent  id  gets partial for dynamic playback 
# parents id  gets partial for dynamic playback

    
    # get all recent items
    # @items = Item.find_all_by_team_id(10000, :conditions => ['updated_at > CURRENT_TIMESTAMP AT TIME ZONE \'UTC'\ - interval \'? days\'', 2])
    
    case params[:type]
      when 'team'
        @items = Item.find_all_by_team_id(params[:team_id], :conditions => ['updated_at > ?::timestamp', ts.to_s])
      when 'item'
        @items = Item.find_all_by_team_id(params[:team_id], :conditions=>['ancestors && ARRAY[?::INT]',params[:id]])
      when 'ch'
        
      when 'par'
        
      when 'pars'

    end
    
    
    # get all unique ids for these items so I can provide context which may be
    # parent item if sib_id = 0
    # sib item if sib_id != 0
    #par_ids = @items.map{ |i| i.par_id }.uniq
    par_ids = @items.find_all{|i| i.sib_id == 0 }.map{ |i| i.par_id }.uniq
    sib_ids = @items.find_all{|i| i.sib_id != 0 }.map{ |i| i.sib_id }.uniq

    # before I get the parent_items and the sib_items, I want to make sure I don't already have them

    # get the ids for items I have already loaded 
    item_ids = @items.map{ |i| i.id }

    # now get the items for ids that have not already been loaded
    @context_items = Item.find_all_by_id( (par_ids + sib_ids - item_ids).uniq )

    # Add an extra attribute so I can identify this as a context item, a non current item added for context?
    @context_items.each{ |i| i[:recent] = false }

    # And identify the recent items as well
    @items.each{ |i| i[:recent] = true }

    # now combine the items
    @items.concat(@context_items)
    
    @items.delete_if {|i| i.o_type == 4 }   # delete teams from this, specifically I want to dump the top level team
    
    # all item_ids
    item_ids = @items.map{ |i| i.id }
    
    # now create ids array for each content type I need to load
    # iterate through the items and creates arrays for each type

    object_ids = {}
    @items.each do |i|
      #logger.debug "item.id #{i.id} recent: #{i[:recent]}, o_type: #{i.o_type}, o_id: #{i.o_id}"
      object_ids[i.o_type] = [] unless object_ids[i.o_type]
      object_ids[i.o_type].push i.o_id
    end
    
    # iterate through each key in the hash and request the data 
    # create array of members
    member_ids = []
    object_ids.keys.each do |type|
      logger.debug "object_ids[#{type}]: #{object_ids[type].inspect}"
      case type
        when 1  # questions
          @questions = Question.find_all_by_id(object_ids[type])
          member_ids.concat(@questions.map{ |i| i.member_id })
        when 2  # answers
          @answers = Answer.find_all_by_id(object_ids[type])
          member_ids.concat(@answers.map{ |i| i.member_id })
        when 3  # comments
          @comments = Comment.find_all_by_id(object_ids[type])
          member_ids.concat(@comments.map{ |i| i.member_id })
          @resources = Resource.find_all_by_comment_id( @comments.map{ |c| c.id } )
        when 5  # chat_sessions
          @chat_sessions = ChatSession.find_all_by_id(object_ids[type])
          member_ids.concat(@chat_sessions.map{ |i| i.member_id })
        when 7  # lists
          @lists = List.find_all_by_id(object_ids[type])
          member_ids.concat(@lists.map{ |i| i.member_id })
          @list_items = ListItem.find_all_by_list_id( @lists.map{ |l| l.id } )
      end    
    end

    # remove duplicates from member_ids array and then get members
    @members = Member.find_all_by_id(member_ids.uniq, :select => 'id, first_name,last_name, pic_id')
    # create a members hash
    @members_by_id = {}
    @members.each { |m| @members_by_id[m.id] = {:first_name=>m.first_name, :last_name=>m.last_name, :pic_id=>m.pic_id}}
    
    # process the items and set the author_name/anonymous, and clear member_id if not the author
    
    
    # get the ratings
    
    @ratings = [] #@team.average_ratings
    @thumbs_ratings = [] # @team.thumbs_ratings
    @my_thumbs_ratings = [] # @team.my_thumbs_ratings( session[:member_id] )
    
    
    # select the top items in the fragments so I can create a set of frament blocks
    # any item whose parent or sibling is not available
    
    @top_items = @items.find_all {|i| i.sib_id == 0 && !item_ids.include?(i.par_id) || i.sib_id != 0 && !item_ids.include?(i.sib_id)}
    
    logger.debug "@top_items: #{@top_items.inspect}"

    # what order do I use for the playback
    #@items_par_0_sorted = @items.find_all {|i| i.par_id == @team_item.id }.sort {|a,b| a.order <=> b.order }
    
    # create the html in the same manner as the transcript using helper 
    
    # if json, do some processing to hide the member_ids
    
  

  end


end