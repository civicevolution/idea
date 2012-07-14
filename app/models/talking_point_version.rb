class TalkingPointVersion < ActiveRecord::Base
  attr_accessible :talking_point_id, :member_id, :version, :text, :lock_member_id
  
end
