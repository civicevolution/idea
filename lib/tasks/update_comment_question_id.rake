namespace :update_comment_question_id do

  desc "Update comments with question_id"
  task :update_comments => :environment do
    puts 'Update comments with question_id'
 
    Comment.record_timestamps = false
    comments = Comment.all()
    puts "There are #{comments.size} comments"
  
    comments.each do |comment|
      case comment.parent_type
        when 1
          comment.question_id = comment.parent_id
        when 13
          comment.question_id = ActiveRecord::Base.connection.select_value(%Q|SELECT question_id FROM talking_points WHERE id = #{comment.parent_id}|).to_i
        when 3
          comment.question_id = ActiveRecord::Base.connection.select_value(%Q|SELECT parent_id FROM comments WHERE id = #{comment.parent_id}|).to_i
      end
      comment.save
    end
    Comment.record_timestamps = true
  end
  
  
end
  
  