class Endorsement < ActiveRecord::Base
  
  validate :check_init_access
  
  attr_accessor :member
  
  def check_init_access
    allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add_to_base("Sorry, you do not have permission to endorse this proposal.") 
      return false
    end
  end
  
end
