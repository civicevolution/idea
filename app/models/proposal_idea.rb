class ProposalIdea < ActiveRecord::Base

  validates_length_of :title, :in => 10..255, :allow_blank => false
  validates_length_of :text, :in => 50..1000, :allow_blank => false
  validates_presence_of :initiative_id
  validates_presence_of :member_id
  validates_presence_of :accept_guidelines, :message => "must accept the ground rules and guidelines"
  validate :member_is_confirmed
  before_validation :check_initiative_restrictions, :on=>:create

  attr_accessor :member
  
  private

    def check_initiative_restrictions
      allowed,message,team_id = InitiativeRestriction.allow_actionX(self.initiative_id, 'suggest_idea', self.member)
      if !allowed
        errors.add(:base, "Sorry, you do not have permission to sugget a proposal to this group.")
        return false
      else
        self.member_id = self.member.id
        return true
      end
    end

    def member_is_confirmed
      errors.add(:base, "You must confirm your CivicEvolution registration before you can submit a proposal idea") unless Member.find_by_id(self.member_id).confirmed
    end



  
end
