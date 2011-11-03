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
          Juggernaut.publish("_auth_team_#{obj.team_id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>obj, 
            :author=>{:first_name=>obj.author.first_name, :last_name=>obj.author.last_name, :ape_code=>obj.author.ape_code, :photo_url=>obj.author.photo.url('36')}})
        
        when  'TalkingPoint'
          event_id = name == 'after_create' ? 3 : 4
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          Juggernaut.publish("_auth_team_#{obj.team.id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>obj})
          
        when  'Answer'
          event_id = name == 'after_create' ? 5 : 6
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when 'Endorsement'
          event_id = name == 'after_create' ? 7 : 8
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => nil,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id,obj)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          Juggernaut.publish("_auth_team_#{obj.team_id}", {:act=>'update_page', :type=>obj.class.to_s, :data=>obj})

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
          
        else
          raise "I didn't know how to process #{obj.class.to_s}"
      end

      if participation_event.save
        Rails.logger.debug "Saved participation event record #{obj.class.to_s}:\n#{participation_event.inspect}"
      else
        raise "I didn't get all the data for #{obj.class.to_s}:\n#{participation_event.inspect}"
      end
      
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
            ParticipationEvent.where(:member_id => params[:member_id], :event_id => event_id).each{|n| n.destroy }
            return
          else
            return if ParticipationEvent.where(:member_id => params[:member_id], :event_id => event_id).exists?
            participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
             :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id,params)
            Rails.logger.debug "participation_event: #{participation_event.inspect}"
          end
          
          
        else
          raise "I don't know how to handle #{name} from Notifications"
      end
      
      if participation_event.save
        Rails.logger.debug "Saved participation event record #{name}:\n#{participation_event.inspect}"
      else
        raise "I couldn't save participation event record for #{name}:\n#{participation_event.inspect}"
      end
      
      
    end
    
    Rails.logger.debug "\n\n\n\n" unless !debug
  end
  
  def self.get_event_id(payload)
    return 1234
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
