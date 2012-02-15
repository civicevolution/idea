class ProposalIdea < ActiveRecord::Base

  validate :check_title_length
  validate :check_text_length
  validates_presence_of :initiative_id
  validates_presence_of :member_id
  validates_presence_of :accept_guidelines, :message => "must accept the ground rules and guidelines"
  validate :member_is_confirmed
  before_validation :check_initiative_restrictions, :on=>:create

  attr_accessor :member
  
  def o_type
    18 #type for ProposalIdea
  end
  def type_text
    'proposal idea' #type for ProposalIdea
  end
  
  def check_title_length
    length = title.scan(/\S/).size
    errors.add(:text, "must be at least 10 characters") unless length >= 10
    errors.add(:text, "must be no longer than 255 characters") unless length <= 255
  end
  
  def check_text_length
    length = text.scan(/\S/).size
    errors.add(:text, "must be at least 50 characters") unless length >= 50
    errors.add(:text, "must be no longer than 1000 characters") unless length <= 1000
  end
  
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
