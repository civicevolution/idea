class IdeaRating < ActiveRecord::Base
  attr_accessible :idea_id, :member_id, :rating
  
  before_validation :check_initiative_restrictions, :on=>:create
  
  def check_initiative_restrictions
    allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:parent_id=>self.id, :parent_type => 20}, 'contribute_to_proposal', self.current_member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to rate an idea.") 
      return false
    end
    true
  end
  
end
