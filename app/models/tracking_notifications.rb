require 'differ'
# move this to library when it is stable
# /lib is not reloaded in dev, but putting this module in models means it will be reloaded each time it is referenced

class TrackingNotifications
  
# See config/participation_event_descriptions.yaml for details and key to event_ids

  def self.process_event(payload)
    # payload[:event]
    # payload[:params] => {"_app_name"=>"2029 and Beyond", "_initiative_id"=>2}
    # payload[:model]
    
    debug = true

    
    name = payload[:event]
    
    Rails.logger.debug "\n\n\n\n" unless !debug
    if payload.key?(:model) # process the model observers
      obj = payload[:model]
      Rails.logger.debug "Process this event #{name} from observer on #{obj.class.to_s}, v3" unless !debug
      Rails.logger.debug obj.inspect unless !debug
      
      case obj.class.to_s
        when 'Comment'
          event_id = name == 'after_create' ? 1 : 2
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question.id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          author = {:first_name=>obj.author.first_name, :last_name=>obj.author.last_name, :ape_code=>obj.author.ape_code, :photo_url=>obj.author.photo.url(:small)}
          mem_id = obj.member_id
          obj.member_id = nil
          Juggernaut.publish("_auth_team_#{obj.team_id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>obj, :author=>author})
          obj.member_id = mem_id

        when  'TalkingPoint'
          event_id = name == 'after_create' ? 3 : 4
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          mem_id = obj.member_id
          obj.member_id = nil
          text = obj.text
          if obj.version > 1
          	old_text = TalkingPointVersion.find_by_talking_point_id_and_version(obj.id,obj.version-1).text
          	Differ.format = :html
            obj.text += '~~DIFF~TEXT~~' + Differ.diff_by_word(obj.text, old_text).to_s
          end
          Juggernaut.publish("_auth_team_#{obj.team.id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>obj})
          obj.member_id = mem_id
          obj.text = text
          
        when  'Answer'
          event_id = name == 'after_create' ? 5 : 6
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when 'Endorsement'
          event_id = name == 'after_create' ? 7 : 8
          return if ParticipationEvent.where(:member_id => obj.member_id, :event_id => event_id, :team_id => obj.team_id).exists?
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => nil, :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          #Juggernaut.publish("_auth_team_#{obj.team_id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>obj})

        when 'ProposalIdea'
          event_id = name == 'after_create' ? 9 : 10
          participation_event = ParticipationEvent.new :initiative_id => obj.initiative_id, :team_id => nil, :question_id => nil,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when 'Invite'
          event_id = name == 'after_create' ? 11 : 12
          participation_event = ParticipationEvent.new :initiative_id => obj.initiative_id, :team_id => obj.team_id, :question_id => nil,
           :item_type => nil, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when 'ContentReport'
          if obj.member_id
            event_id = name == 'after_create' ? 13 : 14
            case obj.content_type
              when 'TalkingPoint'
                team = TalkingPoint.find_by_id(obj.content_id).team
              when 'Comment'
                team = Comment.find_by_id(obj.content_id).team
            end
            team ||= {:id => 0, :initiative_id => 0}
            participation_event = ParticipationEvent.new :initiative_id => team[:initiative_id], :team_id => team[:id], :question_id => nil,
             :item_type => nil, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
            Rails.logger.debug "participation_event: #{participation_event.inspect}"
          end

        when 'InitiativeMembers'
          event_id = name == 'after_create' ? 15 : 16
          participation_event = ParticipationEvent.new :initiative_id => obj.initiative_id, :team_id => nil, :question_id => nil,
           :item_type => nil, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
         
        when  'TalkingPointAcceptableRating' 
          event_id = 17
          tpr = TalkingPointAcceptableRating.sums(obj.talking_point_id)
          rating_votes = [0,0,0,0,0]
          tpr.each{|r| rating_votes[r.rating-1] = r.count.to_i }
          Juggernaut.publish("_auth_team_#{obj.talking_point.team.id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>{:id=>obj.talking_point_id, :votes=>rating_votes}})
          
          return if ParticipationEvent.where(:member_id => obj.member_id, :event_id => event_id, :item_id => obj.id).exists?
          participation_event = ParticipationEvent.new :initiative_id => obj.talking_point.team.initiative_id, :team_id => obj.talking_point.team.id, :question_id => obj.talking_point.question_id,
          :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          #Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when  'TalkingPointPreference' 
          event_id = 19
          preference_count = TalkingPointPreference.count(:member_id, :conditions => ['talking_point_id = ?', obj.talking_point_id ])
          Juggernaut.publish("_auth_team_#{obj.talking_point.team.id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>{:id=>obj.talking_point_id, :count=>preference_count}})
          
          if name == 'after_destroy'
            ParticipationEvent.where(:member_id => obj.member_id, :event_id => event_id, :item_id => obj.id).each{|pe| pe.destroy}
            return
          else
            participation_event = ParticipationEvent.new :initiative_id => obj.talking_point.team.initiative_id, :team_id => obj.talking_point.team.id, :question_id => obj.talking_point.question_id,
            :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
            Rails.logger.debug "participation_event: #{participation_event.inspect}"
          end
          
        when  'AnswerRating'
          event_id = 21
          return if ParticipationEvent.where(:member_id => obj.member_id, :event_id => event_id, :item_id => obj.id).exists?
          participation_event = ParticipationEvent.new :initiative_id => obj.answer.team.initiative_id, :team_id => obj.answer.team.id, :question_id => obj.answer.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          
        when 'Idea'
          if obj.role == 1
            event_id = name == 'after_create' ? 22 : 23
            participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question.id,
            :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          elsif obj.role == 2
            event_id = name == 'after_create' ? 26 : 27
            participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question.id,
            :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          end
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          mem_id = obj.member_id
          obj.member_id = nil
          Juggernaut.publish("_auth_team_#{obj.team_id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>obj})
          obj.member_id = mem_id
          
        when  'IdeaRating' 
          event_id = 24
          rating_votes = IdeaRating.votes(obj.idea_id)
          Juggernaut.publish("_auth_team_#{obj.idea.team.id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>{:id=>obj.idea_id, :votes=>rating_votes}})
          
          return if ParticipationEvent.where(:member_id => obj.member_id, :event_id => event_id, :item_id => obj.id).exists?
          participation_event = ParticipationEvent.new :initiative_id => obj.idea.team.initiative_id, :team_id => obj.idea.team.id, :question_id => obj.idea.question_id,
          :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          #Rails.logger.debug "participation_event: #{participation_event.inspect}"

  
        else
          raise "I didn't know how to process #{obj.class.to_s}"
      end

      update_stat_records(name, participation_event, obj) unless participation_event.nil?
      
    elsif payload.key?(:json) # process the model destroy observers that stored the old model in json
        obj = JSON.parse(payload[:json])
        
        case obj.keys[0]
          when 'talking_point_preference'
            event_id = 19
            tpp = obj['talking_point_preference']
            preference_count = TalkingPointPreference.count(:member_id, :conditions => ['talking_point_id = ?', tpp['talking_point_id'] ])
            talking_point = TalkingPoint.find_by_id(tpp['talking_point_id'])
            if !talking_point.nil?
              Juggernaut.publish("_auth_team_#{talking_point.team.id}", {:act=>'update_page', :type=>'TalkingPointPreference', :data=> {:id=>tpp['talking_point_id'], :count=>preference_count}})
            end
            ParticipationEvent.where(:member_id => tpp['member_id'], :event_id => event_id, :item_id => tpp['id']).each{|pe| pe.destroy}
        end
      
    else # process the controller Notifications
      
      Rails.logger.debug "Process this event #{name} from Notifications" unless !debug
      
      params = payload[:params]
      # Process this event Summary page from Notifications
      # Process this event Question worksheet
      # Process this event New content page 
      case name
        when 'Summary page'
          event_id = 100
          return if ParticipationEvent.where("member_id = ? AND event_id = ? AND team_id = ? AND created_at > now() AT TIME ZONE 'UTC' - interval '1 hour'", params[:member_id], event_id, params[:team_id]).exists?
          #add auth to redis for this user(session_id) and team in the form
          
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          
        when 'Question worksheet'
          event_id = 101
          return if ParticipationEvent.where("member_id = ? AND event_id = ? AND question_id = ? AND created_at > now() AT TIME ZONE 'UTC' - interval '1 hour'", params[:member_id], event_id, params[:question_id]).exists?
          #add auth to redis for this user(session_id) and team in the form
          
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => params[:question_id],
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when 'New content page'
          event_id = 102
          return if ParticipationEvent.where("member_id = ? AND event_id = ? AND team_id = ? AND created_at > now() AT TIME ZONE 'UTC' - interval '1 hour'", params[:member_id], event_id, params[:team_id]).exists?
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
      
        when 'Visit with _mlc'
          event_id = 103
          if params[:question_id] && params[:team_id].nil?
            q = Question.find_by_id(params[:question_id])
            params[:team_id] = q.team_id unless q.nil?
          end
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => params[:question_id],
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
      
        when 'Upload profile photo'
          event_id = 104
          # only count this one time per member
          return if ParticipationEvent.where(:member_id => params[:member_id], :event_id => event_id).exists?
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => nil, :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          
        when 'Request help'
          event_id = 105
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when 'Create new profile'
          event_id = 106
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => nil, :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when 'Update notification settings'
          event_id = 107
          # only record one time
          # remove if the notification was cancelled
          if params[:notification].nil?
            # remove it
            ParticipationEvent.where(:member_id => params[:member_id], :event_id => event_id, :team_id => params[:team_id]).each{|n| n.destroy }
            return
          else
            return if ParticipationEvent.where(:member_id => params[:member_id], :event_id => event_id, :team_id => params[:team_id]).exists?
            participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
             :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
            Rails.logger.debug "participation_event: #{participation_event.inspect}"
          end
          
          
        else
          raise "I don't know how to handle #{name} from Notifications"
      end
      update_stat_records(name, participation_event) unless participation_event.nil?
    end
    
    Rails.logger.debug "\n\n\n\n" unless !debug
  end
  
  def self.update_stat_records(name, participation_event, obj = nil)
    name = obj.nil? ? name : obj.class.to_s
    if participation_event.member_id.nil?
      Rails.logger.debug "Don't save participation event record #{name}, no valid member"
    elsif participation_event.save
      # now update the team and participant summary stats
      if participation_event.team_id # && participation_event.points > 0
        col_name = PARTICIPATION_EVENT_POINTS["item#{participation_event.event_id}"]['col_name']
        if !col_name.nil? && col_name != ''
          part_stats_rec = ParticipantStats.find_by_member_id_and_team_id(participation_event.member_id, participation_event.team_id) || ParticipantStats.new(:member_id => participation_event.member_id, :team_id => participation_event.team_id)
          part_stats_rec[col_name] += 1 unless part_stats_rec[col_name].nil?
          part_stats_rec['points_total'] += participation_event.points
          
          if participation_event.event_id == 100
            # set the day_visits fields
            ldv = part_stats_rec[:last_day_visit]
            ndv = part_stats_rec[:next_day_visit]
            time = Time.now.utc
            if time > ndv
              part_stats_rec[:day_visits] += 1
              if time - ldv - 24.hours > 0
                part_stats_rec[:next_day_visit] = time + 8.hours
              else
                part_stats_rec[:next_day_visit] = ldv + 36.hours
              end
              part_stats_rec[:last_day_visit] = time
            end
          elsif participation_event.event_id == 107
            part_stats_rec[:following] = 1 # simply indicates that participant has adjusted follow settings
          elsif participation_event.event_id == 7
            part_stats_rec[:endorse] = true
          end
          # determine if the level should be increased
          # start at highest level and then let it be decreased by each test, only save it if it is greater than current level
          
          level = 4 

          coms = [0,3,5,6]
          my_coms = part_stats_rec[:comments]
          coms.each_index{|x| if my_coms < coms[x] then level = level >= x ? x : level; break; end }

          rate = [0,1,4,12]
          my_rate = part_stats_rec[:talking_point_ratings]
          rate.each_index{|x| if my_rate < rate[x] then level = level >= x ? x : level; break; end }
          
          favor = [0,1,4,8]
          my_favor = part_stats_rec[:talking_point_preferences]
          favor.each_index{|x| if my_favor < favor[x] then level = level >= x ? x : level; break; end }
          
          talking_points = [0,0,2,4]
          my_tp = part_stats_rec[:talking_points] + part_stats_rec[:talking_point_edits]
          talking_points.each_index{|x| if my_tp < talking_points[x] then level = level >= x ? x : level; break; end }

          visits = [0,2,4,6]
          my_visits = part_stats_rec[:day_visits]
          visits.each_index{|x| if my_visits < visits[x] then level = level >= x ? x : level; break; end }

          invites = [0,0,0,2]
          my_invites = part_stats_rec[:friend_invites]
          invites.each_index{|x| if my_invites < invites[x] then level = level >= x ? x : level; break; end }

          points = [0,500,1200,2000]
          my_points = part_stats_rec[:points_total]
          points.each_index{|x| if my_points < points[x] then level = level >= x ? x : level; break; end }

          part_stats_rec[:level] = level unless level < part_stats_rec[:level]
          
          part_stats_rec.save
          
          team_stats_rec = ProposalStats.find_by_team_id(participation_event.team_id) || ProposalStats.new(:team_id => participation_event.team_id)
          team_stats_rec[col_name] += 1
          team_stats_rec['points_total'] += participation_event.points
          team_stats_rec.save
        end
      end
      Rails.logger.debug "Saved participation event record #{name}:\n#{participation_event.inspect}"
    else
      raise "I didn't get all the data for #{name}:\n#{participation_event.inspect}"
    end
  end
  
  def self.get_event_points(event_id,obj)
    # PARTICIPATION_EVENT_POINTS is read from yaml config file "#{Rails.root}/config/participation_event_descriptions.yaml" in initializers/civicevolution.rb
    points = PARTICIPATION_EVENT_POINTS["item#{event_id}"]['points']
    if PARTICIPATION_EVENT_POINTS["item#{event_id}"]['min_length']
      points = 0 if obj.nil? || obj.text.nil? || obj.text.length < PARTICIPATION_EVENT_POINTS["item#{event_id}"]['min_length']
    end
    return points
  end
  
end
