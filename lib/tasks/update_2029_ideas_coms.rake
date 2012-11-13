namespace :update_2029_ideas_coms do


  desc "get hash for question id change"
  task :update_com_parent_ids => :environment do
    puts 'update_com_parent_ids'
 
    Idea.record_timestamps = false
    Comment.record_timestamps = false
    
    questions = Question.where('team_id in (SELECT id FROM teams WHERE initiative_id in (1))')
    puts "There are #{questions.size} questions"
  	question_map = {}

    questions.each do |question|
			idea_question = Idea.where( role: 3, team_id: question.team_id, order_id: question.order_id)[0]
			question_map[question.id] = {new_question_id: idea_question.id, team_id: idea_question.team_id }
			#puts "OLD: #{question.team_id}, #{question.id}: #{question.text}"
			#puts "NEW: #{idea_question.team_id}, #{idea_question.id}: #{idea_question.text}"
		end
		
		puts question_map.inspect
		
		comments = Comment.where('team_id in (SELECT id FROM teams WHERE initiative_id in (1)) AND parent_type = 1')
    puts "There are #{comments.size} comments"

    comments.each do |comment|
      new_question_id = question_map[ comment.parent_id][:new_question_id]
      puts "Change parent_id from #{comment.parent_id} to #{new_question_id}"
      
      comment.update_attributes({parent_id: new_question_id, question_id: new_question_id, parent_type: 20 })
      
		end

    talking_points = TalkingPoint.where('question_id in (SELECT q.id FROM questions q, teams t WHERE q.team_id = t.id AND t.initiative_id in (1))')
    puts "There are #{talking_points.size} talking_points"

    talking_points.each do |talking_point|
      new_question_id = question_map[ talking_point.question_id][:new_question_id]
      team_id = question_map[ talking_point.question_id][:team_id]
      
      theme = Idea.new text: talking_point.text, is_theme: true, member_id: talking_point.member_id, team_id: team_id, question_id: new_question_id, parent_id: new_question_id, order_id: 1, visible: true, version: 1, created_at: talking_point.created_at, updated_at: talking_point.updated_at, role: 2
      theme.member = Member.find(talking_point.member_id)
      puts "UNCONFIRMED member: #{talking_point.member_id}, talking_point.id: #{talking_point.id}" unless theme.member.confirmed
      puts theme.inspect
      theme.save
      
      
      idea = Idea.new text: talking_point.text, is_theme: false, member_id: talking_point.member_id, team_id: team_id, question_id: new_question_id, parent_id: theme.id, order_id: 1, visible: true, version: 1, created_at: talking_point.created_at, updated_at: talking_point.updated_at, role: 1
      idea.member = Member.find(talking_point.member_id)
      puts "UNCONFIRMED member: #{talking_point.member_id}, talking_point.id: #{talking_point.id}" unless idea.member.confirmed
      puts idea.inspect
      idea.save



		end
		
    Idea.record_timestamps = true
    Comment.record_timestamps = true
  end


  desc "update idea order_id"
  task :update_idea_order_id => :environment do
    puts 'update_idea_order_id'
 
    Idea.record_timestamps = false
    
    questions = Idea.where(role: 3)
    puts "There are #{questions.size} questions"

    questions.each do |question|
      puts "processing question id: #{question.id}"
      # order themes for every question
      Idea.reorder_siblings( question.id, question.themes.map(&:id), nil )
      # order ideas for every theme
      question.themes.each do |theme|
        Idea.reorder_siblings( theme.id, theme.theme_ideas.map(&:id), nil )
      end

      # order ideas where parent_id is null or 0	
      Idea.reorder_siblings( "null", question.unthemed_ideas.map(&:id), nil )
      Idea.reorder_siblings( 0, question.parked_ideas.map(&:id), nil )
		end
		
    Idea.record_timestamps = true
  end

	
    
end
  
  