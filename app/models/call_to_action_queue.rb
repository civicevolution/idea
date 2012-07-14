class CallToActionQueue < ActiveRecord::Base
  
  attr_accessible :team_id, :member_id, :sent, :scenario
  
end
