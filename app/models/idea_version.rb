class IdeaVersion < ActiveRecord::Base
  attr_accessible :idea_id, :lock_member_id, :member_id, :text, :version
end
