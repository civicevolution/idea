# move this to library when it is stable
# /lib is not reloaded in dev, but putting this module in models means it will be reloaded each time it is referenced

class TrackingNotifications
  
  #  id |       description       
  # ----+-------------------------
  #   1 | Add comment             
  #   2 | Edit comment            
  #   3 | Add talking point       
  #   4 | Edit talking point      
  #   5 | Add answer              
  #   6 | Edit answer             
  #   7 | Endorse  
  #   8 | Update endorsement
  #   9 | Add proposal idea
  #  10 | Update proposal idea              
  #  100 | Summary page
  #  101 | Question worksheet
  #  102 | New content page
  #  201 | Invite a friend         
  #  203 | Visit with _mlc code    
  
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
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when  'TalkingPoint'
          event_id = name == 'after_create' ? 3 : 4
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when  'Answer'
          event_id = name == 'after_create' ? 5 : 6
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when 'Endorsement'
          event_id = name == 'after_create' ? 7 : 8
          participation_event = ParticipationEvent.new :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => nil,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when 'ProposalIdea'
          event_id = name == 'after_create' ? 9 : 10
          participation_event = ParticipationEvent.new :initiative_id => obj.initiative_id, :team_id => nil, :question_id => nil,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when 'Invite'
          event_id = name == 'after_create' ? 11 : 12
          participation_event = ParticipationEvent.new :initiative_id => obj.initiative_id, :team_id => obj.team_id, :question_id => nil,
           :item_type => nil, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
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
             :item_type => nil, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
            Rails.logger.debug "participation_event: #{participation_event.inspect}"
          end

        when 'InitiativeMembers'
          event_id = name == 'after_create' ? 15 : 16
          participation_event = ParticipationEvent.new :initiative_id => obj.initiative_id, :team_id => nil, :question_id => nil,
           :item_type => nil, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
         
        when  'TalkingPointAcceptableRating' 
          event_id = name == 'after_create' ? 17 : 18
          participation_event = ParticipationEvent.new :initiative_id => obj.talking_point.team.initiative_id, :team_id => obj.talking_point.team.id, :question_id => obj.talking_point.question_id,
          :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when  'TalkingPointPreference' 
          event_id = name == 'after_create' ? 19 : 20
          participation_event = ParticipationEvent.new :initiative_id => obj.talking_point.team.initiative_id, :team_id => obj.talking_point.team.id, :question_id => obj.talking_point.question_id,
          :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when  'AnswerRating'
          event_id = name == 'after_create' ? 21 : 22
          participation_event = ParticipationEvent.new :initiative_id => obj.answer.team.initiative_id, :team_id => obj.answer.team.id, :question_id => obj.answer.question_id,
           :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          
        else
          raise "I didn't know how to process #{obj.class.to_s}"
      end

      if participation_event.save
        Rails.logger.debug "Saved participation event record #{obj.class.to_s}:\n#{participation_event.inspect}"
      else
        raise "I didn't get all the data for #{obj.class.to_s}:\n#{participation_event.inspect}"
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
          return if ParticipationEvent.where("member_id = ? AND event_id = ? AND created_at > now() AT TIME ZONE 'UTC' - interval '1 hour'", params[:member_id], event_id).exists?
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          
        when 'Question worksheet'
          event_id = 101
          return if ParticipationEvent.where("member_id = ? AND event_id = ? AND created_at > now() AT TIME ZONE 'UTC' - interval '1 hour'", params[:member_id], event_id).exists?
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => params[:question_id],
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
        
        when 'New content page'
          event_id = 102
          return if ParticipationEvent.where("member_id = ? AND event_id = ? AND created_at > now() AT TIME ZONE 'UTC' - interval '1 hour'", params[:member_id], event_id).exists?
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
      
        when 'Visit with _mlc'
          event_id = 103
          if params[:question_id] && params[:team_id].nil?
            q = Question.find_by_id(params[:question_id])
            params[:team_id] = q.team_id unless q.nil?
          end
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => params[:question_id],
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
      
        when 'Upload profile photo'
          event_id = 104
          # only count this one time per member
          return if ParticipationEvent.where(:member_id => params[:member_id], :event_id => event_id).exists?
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => nil, :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"
          
        when 'Request help'
          event_id = 105
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => params[:team_id], :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
          Rails.logger.debug "participation_event: #{participation_event.inspect}"

        when 'Create new profile'
          event_id = 106
          participation_event = ParticipationEvent.new :initiative_id => params[:_initiative_id], :team_id => nil, :question_id => nil,
           :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
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
             :item_type => nil, :item_id => nil, :member_id => params[:member_id], :event_id => event_id, :points => get_event_points(event_id)
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
  
  def self.get_event_points(event_id)
    return 10000
  end
  
end
