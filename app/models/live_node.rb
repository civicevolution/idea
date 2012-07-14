class LiveNode < ActiveRecord::Base
  attr_accessible :live_event_id, :name, :description, :parent_id, :username, :password, :role, :jug_id
  
end
