class Rating < ActiveRecord::Base

  has_one :item
  
  validate :check_rating_access
  
  attr_accessor :team_id
  
end
