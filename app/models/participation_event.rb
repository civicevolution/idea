class ParticipationEvent < ActiveRecord::Base
  attr_accessible :initiative_id, :team_id, :question_id, :item_type, :item_id, :member_id, :event_id, :points, :created_at, :updated_at
  
end
