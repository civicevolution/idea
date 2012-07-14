class BsIdeaFavoritePriority < ActiveRecord::Base
  
  validate :check_init_access
  
  attr_accessible :question_id, :member_id, :priority
  
  attr_accessor :member
  
  def check_init_access
    allowed,message = InitiativeRestriction.allow_action({:question_id=>self.question_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add_to_base("Sorry, you do not have permission to prioritize favorite brainstorming ideas.") 
      return false
    end
  end
  
end
