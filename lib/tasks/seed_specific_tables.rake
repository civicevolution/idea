namespace :seed_specific_tables do

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


  desc "add answers into participation events"
  task :make_answer_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    answer_vers = AnswerDiff.where('answer_id IN (SELECT id FROM answers WHERE team_id > 10017) AND member_id != 1 ')
    puts "There are #{answer_vers.size} answer_vers"
    answer_vers.each do |obj|
      puts "Processing answer_vers id: #{obj.id}"
      event_id = obj.version == 1 ? 5 : 6
      participation_event = ParticipationEvent.create :initiative_id => obj.answer.team.initiative_id, :team_id => obj.answer.team.id, :question_id => obj.answer.question_id,
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
      puts "Processing endorsement id: #{obj.id}"
      event_id = 9
      participation_event = ParticipationEvent.create :initiative_id => obj.initiative_id, :team_id => nil, :question_id => nil,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
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

  desc "add answers into participation events"
  task :make_answer_rating_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    answer_ratings = AnswerRating.all
    puts "There are #{answer_ratings.size} answer_ratings"
    answer_ratings.each do |obj|
      puts "Processing answer_ratings id: #{obj.id}"
      event_id = 21
      participation_event = ParticipationEvent.create :initiative_id => obj.answer.team.initiative_id, :team_id => obj.answer.team.id, :question_id => obj.answer.question_id,
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

  desc "add talking_points into participation events"
  task :make_talking_points_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    talking_points = TalkingPoint.where('question_id IN (SELECT id FROM questions WHERE team_id > 10017) AND member_id != 1 ')
    puts "There are #{talking_points.size} talking_points"
    talking_points.each do |obj|
      puts "Processing talking_points id: #{obj.id}"
      event_id = 3
      participation_event = ParticipationEvent.create :initiative_id => obj.team.initiative_id, :team_id => obj.team.id, :question_id => obj.question_id,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end    
  end

  desc "add talking_point_acceptable_ratings into participation events"
  task :make_talking_point_acceptable_ratings_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    talking_point_acceptable_ratings = TalkingPointAcceptableRating.where('talking_point_id IN (SELECT id FROM talking_points WHERE question_id IN (SELECT id FROM questions WHERE team_id > 10017)) AND member_id != 1 ')
    puts "There are #{talking_point_acceptable_ratings.size} talking_point_acceptable_ratings"
    talking_point_acceptable_ratings.each do |obj|
      puts "Processing talking_point_acceptable_ratings id: #{obj.id}"
      event_id = 17
      participation_event = ParticipationEvent.create :initiative_id => obj.talking_point.team.initiative_id, :team_id => obj.talking_point.team.id, :question_id => obj.talking_point.question_id,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
    end    
  end

  desc "add talking_point_preferences into participation events"
  task :make_talking_point_preferences_participation_events => :environment do
    ParticipationEvent.record_timestamps = false
    talking_point_preferences = TalkingPointPreference.where('talking_point_id IN (SELECT id FROM talking_points WHERE question_id IN (SELECT id FROM questions WHERE team_id > 10017)) AND member_id != 1 ')
    puts "There are #{talking_point_preferences.size} talking_point_preferences"
    talking_point_preferences.each do |obj|
      puts "Processing talking_point_preferences id: #{obj.id}"
      event_id = 19
      participation_event = ParticipationEvent.create :initiative_id => obj.talking_point.team.initiative_id, :team_id => obj.talking_point.team.id, :question_id => obj.talking_point.question_id,
       :item_type => obj.o_type, :item_id => obj.id, :member_id => obj.member_id, :event_id => event_id, :created_at => obj.created_at, :updated_at => obj.updated_at
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

  desc "add comments into participation events"
  task :assign_participation_event_points => :environment do
    ParticipationEvent.record_timestamps = false
    events = ParticipationEvent.all
    puts "There are #{events.size} events"
    events.each do |event|
      puts "Processing events id: #{event.id}"
      obj = event.event_id == 1 ? Comment.find_by_id(event.item_id) : nil
      event.points = TrackingNotifications.get_event_points(event.event_id, obj)
      event.save
    end
  end

  task :seed_proposal_stats_table => :environment do
    
    
    teams = Team.order('id ASC')
    puts "There are #{teams.size} teams"
    teams.each do |team|
      puts "Processing teams id: #{team.id}"

      stats_rec = ProposalStats.find_by_team_id(team.id) || ProposalStats.new(:team_id => team.id)
      stats_rec.participants = ActiveRecord::Base.connection.select_value("SELECT COUNT(DISTINCT(member_id)) FROM participation_events WHERE team_id = #{team.id};").to_i
      stats_rec.points = ActiveRecord::Base.connection.select_value("SELECT SUM(points) FROM Participation_events WHERE team_id = #{team.id};").to_i
      
      team.stats.each do |stat|
        stats_rec[stat[:col_name]] = stat[:count].to_i unless stat[:col_name] == ''
      end
      
      # estimate the base for views
      stats_rec.proposal_views_base = 
        stats_rec.endorsements * 5  +
        stats_rec.talking_points * 8 +
        stats_rec.comments * 4 +
        stats_rec.participants * 4 +
        stats_rec.followers * 4

      stats_rec.question_views_base = 
        stats_rec.endorsements * 3  +
        stats_rec.talking_points * 6 +
        stats_rec.comments * 4
      
      puts stats_rec.inspect
      
      stats_rec.save

    end
  end

  
end