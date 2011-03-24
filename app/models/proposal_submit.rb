class ProposalSubmit < ActiveRecord::Base

  validate :check_init_access
  
  attr_accessor :member
  
  def check_init_access
    # this is access check for the idea page version
    #allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'submit_proposal', self.member)
    #@team = Team.find(self.team_id)
    #allowed = @team.org_id == self.member.id ? true : false
    #if !allowed
    #  errors.add_to_base("Sorry, only the idea originator can submit this proposal.") 
    #  return false
    #end
    
    # allow anyone to submit for the immediate time being
  end

end
