class Endorsement < ActiveRecord::Base
  
  validate :check_init_access
  has_one :member, :class_name => 'Member', :foreign_key => 'id', :primary_key => 'member_id'
  
  attr_accessor :member
  
  def check_init_access
    allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add_to_base("Sorry, you do not have permission to endorse this proposal.") 
      return false
    end
  end
  
end
