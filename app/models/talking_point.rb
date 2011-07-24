class TalkingPoint < ActiveRecord::Base

  belongs_to :question
	has_many :talking_point_acceptable_ratings
	#has_many :talking_point_preferences
	#has_many :talking_point_preferences, :finder_sql =>
  #          proc { "SELECT COUNT(member_id) AS cnt FROM talking_point_preferences where talking_point_id = #{id}" }	
  has_many :talking_point_preferences, :finder_sql => proc {"SELECT COUNT(member_id) AS cnt FROM talking_point_preferences where talking_point_id = #{id}"}
  
	has_many :talking_point_versions          
	has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 13'
  
  attr_accessor :preference_votes
  attr_accessor :rating_votes 
  attr_accessor :my_preference
  attr_accessor :my_rating
  attr_accessor :coms
  attr_accessor :new_coms
  

  def self.com_counts(talking_point_ids, last_visit_ts)
    ActiveRecord::Base.connection.select_all(
    %Q|select talking_point_id,
    (select count(id) from comments where parent_type=13 and parent_id = talking_point_id) AS coms,
    (SELECT count(id) from comments where parent_type=13 and parent_id = talking_point_id AND created_at > '#{last_visit_ts}') AS new_coms
    FROM ( VALUES #{ talking_point_ids.map{ |id| "(#{id})" }.join(',') } ) AS t (talking_point_id)|
    )
  end

  def self.get_and_assign_stats( question, member )
    
    question.talking_points_to_display = question.talking_points
    talking_point_ids = []
    comment_member_ids = []
    question.talking_points_to_display.each do |tp| 
      talking_point_ids << tp.id
    end
    
    tpp = TalkingPointPreference.sums(talking_point_ids)
    tpr = TalkingPointAcceptableRating.sums(talking_point_ids)
    my_preferences = TalkingPointPreference.my_votes(talking_point_ids, member.id)
    my_ratings = TalkingPointAcceptableRating.my_votes(talking_point_ids, member.id)
    talking_point_coms = TalkingPoint.com_counts(talking_point_ids, member.last_visit_ts)

    Team.assign_stats( 
      :questions => [question],
      :talking_point_coms => talking_point_coms,
      :tpp => tpp,
      :tpr => tpr, 
      :my_preferences => my_preferences,
      :my_ratings => my_ratings
    )
  end
  
    
end
