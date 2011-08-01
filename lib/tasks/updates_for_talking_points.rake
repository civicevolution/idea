namespace :update_for_talking_points do
  
  desc "Update comments with parent_type and parent_id, mostly for questions"
  task :update_comments => :environment do
    puts 'Update comments with parent_type and parent_id, mostly for questions'
 
    #puts "Exiting: Make sure I disable the Comment.after_save :log_team_content when I do the updates OR disable notify and then clear the !!!!"
    #exit
 
    Comment.record_timestamps = false
    comments = Comment.all()
    puts "There are #{comments.size} comments"
  
    comments.each do |comment|
      #puts "comment: #{comment.inspect}"
      #puts "comments.id: #{comment.id}"
      #comment = Comment.find(443)
      com_item = Item.find_by_o_id_and_o_type(comment.id, 3)
      #puts "com_item: #{com_item.inspect}"
      question_item = Item.first(:conditions => ['team_id = ? and o_type = 1 AND ARRAY[id] && ?', com_item.team_id, com_item.ancestors ])
      #puts "question_item: #{question_item.inspect}"
      

      
      if !question_item.nil?
        comment.parent_type = question_item.o_type
        comment.update_attribute('parent_id',question_item.o_id)
        # update_attribute will update both attributes and not do validation
        puts comment.inspect
      end
    end
    Comment.record_timestamps = true
  end
  
    
  desc "Update questions with team_id, order and talking points data"
  task :update_questions => :environment do

    puts 'Update questions with team_id, order and talking points data'
 
    questions = Question.all()
    puts "There are #{questions.size} questions"
  
    questions.each do |question|
      puts "question.id: #{question.id}"
      question_item = Item.find_by_o_id_and_o_type(question.id, 1)
      if !question_item.nil?
        puts question_item.inspect
      
        page_item = Item.find_by_id(question_item.par_id)
        puts page_item.inspect
      
        if !page_item.nil?
          question.order_id = page_item.order
          question.team_id = page_item.team_id
          question.talking_point_criteria = '20..200'
          #question.talking_point_preferences = 5
          question.update_attribute('talking_point_preferences',5)
          # update_attribute will update both attributes and not do validation
          puts question.inspect
        end
      end
    end
    
  end

  desc "Move item_diffs and item_versions into answer_diffs"
  task :create_answer_diffs => :environment do
    puts "Move item_diffs and item_versions into answer_diffs"
    
    AnswerDiff.record_timestamps = false
    item_diffs = ItemDiff.where('o_type = 2')
    puts "There are #{item_diffs.size} item_diffs"
  
    item_diffs.each do |item_diff|
      puts "item_diff.id: #{item_diff.id}"
      item_version = ItemVersions.find_by_item_id_and_item_type_and_ver(item_diff.o_id, item_diff.o_type,item_diff.ver)
      
      
      answer_diff = AnswerDiff.new(:answer_id => item_diffs, :member_id => item_diff.member_id, :version => item_diff.ver)
      answer_diff.created_at = item_diff.created_at
      answer_diff.updated_at = item_diff.updated_at
      answer_diff.text = item_version.nil? ? '' : item_version.text
      answer_diff.diff = item_diff.diff
      #puts answer_diff.inspect
      puts "saving answer_diff for answer_id: #{answer_diff.answer_id}"
      answer_diff.save

    end
    AnswerDiff.record_timestamps = true
  end

  desc "Create talking_point item_type"
  task :create_talking_point_item_type => :environment do
    puts "Create talking_point item_type"
    item_type = ItemType.new
    item_type.type = 'talking_point'
    item_type.description = 'talking_point'
    item_type.id = 13
    item_type.save
  end

    
end
  
  