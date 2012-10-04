class IdeaRating < ActiveRecord::Base
  attr_accessible :idea_id, :member_id, :member, :rating
  attr_accessor :member
  attr_accessor :team_id
  attr_accessor :num_idea_votes
  
  belongs_to :idea
  
  before_validation :check_initiative_restrictions, :on=>:create
  
  def check_initiative_restrictions
    allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:idea_id=>self.idea_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to rate an idea.") 
      return false
    end
    true
  end
  
  def self.votes(idea_id)
    IdeaRating.where(idea_id: idea_id ).pluck('rating')
  end
  
  after_save do |rating|
    rating.num_idea_votes = IdeaRating.where( idea_id: rating.idea_id).count
  end
  
  def o_type
    21 #type for Idea
  end
  def type_text
    'idea rating' #type for Idea
  end
  
  
end
