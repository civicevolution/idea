class Rating < ActiveRecord::Base

  has_one :item
  
  validate :check_rating_access
  
  attr_accessible :item_id, :member_id, :rating
  
  attr_accessor :team_id
  
end
