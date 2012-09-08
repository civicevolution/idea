class IdeaRating < ActiveRecord::Base
  attr_accessible :idea_id, :member_id, :rating
end
