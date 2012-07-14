class ThumbsRating < ActiveRecord::Base
  
  has_one :item
  
  validate :check_rating_access
  
  attr_accessible :item_id, :member_id, :up, :down
  
  attr_accessor :team_id
      
end
