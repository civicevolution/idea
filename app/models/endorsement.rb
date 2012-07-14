class Endorsement < ActiveRecord::Base
  
  validate :check_init_access
  has_one :member, :class_name => 'Member', :foreign_key => 'id', :primary_key => 'member_id'
  belongs_to :team
  
  attr_accessible :team_id, :member_id, :text
  
  
  def check_init_access
    allowed,message = InitiativeRestriction.allow_actionX({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to endorse this proposal.") 
      return false
    end
  end
  
  def o_type
    19 #type for Endorsement
  end
  def type_text
    'endorsement' #type for Answers
  end
  
end
