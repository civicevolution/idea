class TalkingPointAcceptableRating < ActiveRecord::Base
  
  scope :sums, lambda { select('talking_point_id, rating, count(member_id)').group('talking_point_id, rating') }
  
  scope :my_votes, lambda { |ids,member_id| select('talking_point_id, rating').where("talking_point_id IN(?) AND member_id = ?", ids, member_id) }

  attr_accessor :member
    
  before_validation :check_initiative_restrictions
  
  def check_initiative_restrictions
    #logger.debug "TalkingPointAcceptableRating.check_initiative_restrictions"
    allowed,message = InitiativeRestriction.allow_actionX({:talking_point_id=>self.talking_point_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add_to_base("Sorry, you do not have permission to rate this talking point.") 
      return false
    end
    true
  end
  
  
end
