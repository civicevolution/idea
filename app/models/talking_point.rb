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
    
end
