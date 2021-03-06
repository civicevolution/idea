namespace :update_participation_stats do

  desc "Seed participation_event_descriptions"
  task :participation_event_descriptions => :environment do 
    puts "Do Seed participation_event_descriptions"
    yml = YAML.load_file "#{Rails.root}/config/participation_event_descriptions.yaml"
  
    yml.each_pair { |key, value|
      rec = value
      # create a record
      event = ParticipationEventDetail.new :description => rec['description']
      event.id = rec['id']
      event.save   
    }
    puts "End Seed participation_event_descriptions"
  end

  desc "Seed item_types"
  task :add_item_types => :environment do 
    puts "Add item_types from file"
    yml = YAML.load_file "#{Rails.root}/config/item_types.yaml"
  
    #yml.each_pair { |key, value| rec = value; puts rec['type'], rec['description']}
    yml.each_pair { |key, value|
      rec = value
      # create a record
      item = ItemType.new :description => rec['description']
      item.id = rec['id']
      item.type = rec['type']
      item.save   
    }
    puts "End Seed item_types"
  end
  
  desc "add comments into participation events"
  task :make_comment_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    comments = Comment.where('team_id > 10017 AND member_id != 1 ')
    puts "There are #{comments.size} comments"
    comments.each do |obj|
      puts "Processing comment id: #{obj.id}"
      event_id = 1
      participation_event = ParticipationEvent.create :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question.id,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end
  end

  desc "add endorsements into participation events"
  task :make_endorsement_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    endorsements = Endorsement.where('team_id > 10017 AND member_id != 1 ')
    puts "There are #{endorsements.size} endorsements"
    endorsements.each do |obj|
      puts "Processing endorsement id: #{obj.id}"
      event_id = 7
      participation_event = ParticipationEvent.create :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => nil,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end
  end
  
  desc "add proposal ideas into participation events"
  task :make_proposal_ideas_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    proposal_ideas = ProposalIdea.where('member_id != 1 ')
    puts "There are #{proposal_ideas.size} proposal_ideas"
    proposal_ideas.each do |obj|
      puts "Processing proposal_idea id: #{obj.id}"
      event_id = 9
      participation_event = ParticipationEvent.create :initiative_id => obj.initiative_id, :team_id => nil, :question_id => nil,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end
  end

  desc "add proposal ideas into participation events for each team"
  task :make_team_proposal_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    teams = Team.where('id > 10017')
    puts "There are #{teams.size} teams"
    teams.each do |obj|
      puts "Processing teams id: #{obj.id}"
      event_id = 9
      participation_event = ParticipationEvent.create :initiative_id => obj.initiative_id, :team_id => obj.id, :question_id => nil,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.org_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end
  end
  
  desc "add initiative membership into participation events"
  task :make_initiative_members_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    initiative_members = InitiativeMembers.all
    puts "There are #{initiative_members.size} initiative_members"
    initiative_members.each do |obj|
      puts "Processing initiative_member id: #{obj.id}"
      event_id = 15
      participation_event = ParticipationEvent.create :initiative_id => obj.initiative_id, :team_id => nil, :question_id => nil,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end
  end

  desc "add members into participation events"
  task :make_members_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    members = Member.all
    puts "There are #{members.size} members"
    members.each do |obj|
      puts "Processing members id: #{obj.id}"
      event_id = 106
      participation_event = ParticipationEvent.create :initiative_id => nil, :team_id => nil, :question_id => nil,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end
  end

  desc "add notification_requests into participation events"
  task :make_notification_requests_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    notification_requests = NotificationRequest.where('team_id > 10017')
    puts "There are #{notification_requests.size} notification_requests"
    notification_requests.each do |obj|
      puts "Processing notification_request id: #{obj.id}"
      event_id = 107
      participation_event = ParticipationEvent.create :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => nil,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end
  end

  desc "add ideas into participation events"
  task :make_ideas_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    ideas = Idea.where('team_id > 10017 AND member_id != 1 AND role BETWEEN 1 AND 2')
    puts "There are #{ideas.size} ideas"
    ideas.each do |obj|
      puts "Processing ideas id: #{obj.id}"
      
      if obj.role == 1
        event_id = 22
      elsif obj.role == 2
        event_id = 26
      end
      participation_event = ParticipationEvent.create :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end    
  end

  desc "add idea_ratings into participation events"
  task :make_idea_ratings_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    idea_ratings = IdeaRating.where('idea_id IN (SELECT id FROM ideas WHERE team_id > 10017) AND member_id != 1 ')
    puts "There are #{idea_ratings.size} idea_ratings"
    idea_ratings.each do |obj|
      puts "Processing idea_ratings id: #{obj.id}"
      event_id = 24
      participation_event = ParticipationEvent.create :initiative_id => obj.idea.team.initiative_id, :team_id => obj.idea.team.id, :question_id => obj.idea.question_id,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end    
  end



  desc "assign event points"
  task :assign_participation_event_points => :environment do
    ParticipationEvent.record_timestamps = false
    events = ParticipationEvent.all
    puts "There are #{events.size} events"
    events.each do |event|
      puts "Processing events id: #{event.id}"
      obj = nil
      case
        when event.event_id == 1
          obj = Comment.find_by_id(event.item_id)
        when event.event_id == 22
          obj = Idea.find_by_id(event.item_id)  
      end
      event.points = TrackingNotifications.get_event_points(event.event_id, obj)
      event.save
    end
  end

  task :seed_participant_stats_table => :environment do
    Team.order('id ASC').each do |team|
      puts "Processing teams id: #{team.id}"

      # for each team, get the distinct participants
      participant_ids = ActiveRecord::Base.connection.select_values("SELECT DISTINCT(member_id) FROM participation_events WHERE team_id = #{team.id};")
      puts "participant_ids: #{participant_ids}"
      participant_ids.each do |participant_id|

        puts "participant_id: #{participant_id}"
        participant = Member.find_by_id(participant_id)
        next if participant.nil?

        puts "Create participant_stats record for team #{team.id} and member: #{participant.id}"

        stats_rec = ParticipantStats.find_by_member_id_and_team_id(participant.id, team.id) || ParticipantStats.new(:member_id => participant.id, :team_id => team.id)

        notify = NotificationRequest.find_by_member_id_and_team_id(participant.id, team.id)
        stats_rec.following = notify.nil? ? 0 : notify.report_type

        stats_rec.endorse = Endorsement.find_by_member_id_and_team_id(participant.id, team.id).nil? ? false : true

        # get the counts

        participation_counts = ActiveRecord::Base.connection.select_all(
        %Q|select 
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 100) AS proposal_views,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 101) AS question_views,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 11) AS friend_invites,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 3) AS ideas,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 17) AS idea_ratings,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 1) AS comments,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 13) AS content_reports,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id}) AS points_total,        
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '1 days') AS points_days1,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '3 days') AS points_days3,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '7 days') AS points_days7,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '14 days') AS points_days14,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '28 days') AS points_days28,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '90 days') AS points_days90
        |)[0]

        stats_rec.proposal_views = participation_counts['proposal_views'].to_i
        stats_rec.question_views = participation_counts['question_views'].to_i
        stats_rec.friend_invites = participation_counts['friend_invites'].to_i
        stats_rec.ideas = participation_counts['ideas'].to_i
        stats_rec.idea_ratings = participation_counts['idea_ratings'].to_i
        stats_rec.comments = participation_counts['comments'].to_i
        stats_rec.content_reports = participation_counts['content_reports'].to_i

        stats_rec.points_total = participation_counts['points_total'].to_i
        stats_rec.points_days1 = participation_counts['points_days1'].to_i
        stats_rec.points_days3 = participation_counts['points_days3'].to_i
        stats_rec.points_days7 = participation_counts['points_days7'].to_i
        stats_rec.points_days14 = participation_counts['points_days14'].to_i
        stats_rec.points_days28 = participation_counts['points_days28'].to_i
        stats_rec.points_days90 = participation_counts['points_days90'].to_i

        last_visit = ParticipationEvent.where(:member_id => participant.id, :team_id => team.id).last
        stats_rec.last_visit = last_visit.nil? ? nil : last_visit.created_at
        
        
        # set the participants level following these simplistic rules
        # start at highest level
        
        stats_rec.day_visits = participation_counts['proposal_views'].to_i + participation_counts['comments'].to_i + participation_counts['comments'].to_i
        
        level = 4 

        coms = [0,3,5,6]
        my_coms = stats_rec[:comments]
        coms.each_index{|x| if my_coms < coms[x] then level = level >= x ? x : level; break; end }


        # set the level according to activity
        #rate = [0,1,4,12]
        #my_rate = stats_rec[:idea_ratings]
        #rate.each_index{|x| if my_rate < rate[x] then level = level >= x ? x : level; break; end }
        #
        #favor = [0,1,4,8]
        #my_favor = stats_rec[:talking_point_preferences]
        #favor.each_index{|x| if my_favor < favor[x] then level = level >= x ? x : level; break; end }
        #

        visits = [0,2,4,6]
        my_visits = stats_rec[:day_visits]
        visits.each_index{|x| if my_visits < visits[x] then level = level >= x ? x : level; break; end }

        invites = [0,0,0,2]
        my_invites = stats_rec[:friend_invites]
        invites.each_index{|x| if my_invites < invites[x] then level = level >= x ? x : level; break; end }

        points = [0,500,1200,2000]
        my_points = stats_rec[:points_total]
        points.each_index{|x| if my_points < points[x] then level = level >= x ? x : level; break; end }

        stats_rec[:level] = level
        
        
        stats_rec.save
      end
    end
  end

  task :seed_proposal_stats_table => :environment do
    teams = Team.order('id ASC')
    puts "There are #{teams.size} teams"
    teams.each do |team|
      puts "Processing teams id: #{team.id}"

      stats_rec = ProposalStats.find_by_team_id(team.id) || ProposalStats.new(:team_id => team.id)
      stats_rec.participants = ActiveRecord::Base.connection.select_value("SELECT COUNT(DISTINCT(member_id)) FROM participation_events WHERE team_id = #{team.id} AND member_id > 15").to_i
      
      participation_counts = ActiveRecord::Base.connection.select_all(
      %Q|SELECT SUM(points_total) AS points_total, SUM(points_days1) AS points_days1, SUM(points_days3) AS points_days3, SUM(points_days7) AS points_days7, 
      SUM(points_days14) AS points_days14, SUM(points_days28) AS points_days28, SUM(points_days90) AS points_days90 FROM participant_stats WHERE team_id = #{team.id}|)[0]
      
      stats_rec.points_total = participation_counts['points_total'].to_i
      stats_rec.points_days1 = participation_counts['points_days1'].to_i
      stats_rec.points_days3 = participation_counts['points_days3'].to_i  
      stats_rec.points_days7 = participation_counts['points_days7'].to_i
      stats_rec.points_days14 = participation_counts['points_days14'].to_i
      stats_rec.points_days28 = participation_counts['points_days28'].to_i
      stats_rec.points_days90 = participation_counts['points_days90'].to_i
      
      stats = []
      event_records = ActiveRecord::Base.connection.select_rows("SELECT event_id, COUNT(id), SUM(points) FROM participation_events WHERE team_id = #{team.id} GROUP BY event_id")
      event_records.each do |er| 
      	pep = PARTICIPATION_EVENT_POINTS["item#{er[0]}"]
      	stats.push(:title => pep['summary_title'], :count => er[1], :points => er[2], :order=>pep['summary_order'], :col_name => pep['col_name'])
      end
      
      stats.each do |stat|
        stats_rec[stat[:col_name]] = stat[:count].to_i unless stat[:col_name] == ''
      end
      
      # estimate the base for views
      if team.initiative_id.between?(1,2)
        stats_rec.proposal_views_base = 
          stats_rec.endorsements * 5  +
          stats_rec.ideas * 8 +
          stats_rec.comments * 4 +
          stats_rec.participants * 4 +
          stats_rec.followers * 4

        stats_rec.question_views_base = 
          stats_rec.endorsements * 3  +
          stats_rec.ideas * 6 +
          stats_rec.comments * 4
      else
        stats_rec.proposal_views_base = 
          stats_rec.endorsements * 2  +
          stats_rec.ideas * 2 +
          stats_rec.comments * 2 +
          stats_rec.followers * 2

        stats_rec.question_views_base = 0
      end
      stats_rec.points_total += stats_rec.proposal_views_base * 20
      
      puts stats_rec.inspect
      
      stats_rec.save

    end
    
  end

  
end