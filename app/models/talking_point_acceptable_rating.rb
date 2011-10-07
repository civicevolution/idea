class TalkingPointAcceptableRating < ActiveRecord::Base
  
  belongs_to :talking_point
  
  scope :sums, lambda { |ids| select('talking_point_id, rating, count(member_id)').group('talking_point_id, rating').where("talking_point_id IN(?)", ids) }
  
  scope :my_votes, lambda { |ids,member_id| select('talking_point_id, rating').where("talking_point_id IN(?) AND member_id = ?", ids, member_id) }

  attr_accessor :member
    
  before_validation :check_initiative_restrictions
  
  def check_initiative_restrictions
    #logger.debug "TalkingPointAcceptableRating.check_initiative_restrictions"
    allowed,message = InitiativeRestriction.allow_actionX({:talking_point_id=>self.talking_point_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to rate this talking point.") 
      return false
    end
    true
  end
  
  def self.record( member, talking_point_id, rating)
    rating_rec = TalkingPointAcceptableRating.find_by_member_id_and_talking_point_id(member.id, talking_point_id)
    
    if rating_rec.nil?
      rating_rec = TalkingPointAcceptableRating.new( :member_id=> member.id, :talking_point_id=> talking_point_id )
    end
    rating_rec.member = member
    rating_rec.rating = rating
    rating_rec.save
    talking_point = TalkingPoint.find( talking_point_id )

    tpr = TalkingPointAcceptableRating.sums(talking_point.id)
    talking_point.rating_votes = [0,0,0,0,0]
    tpr.select{|rec| rec.talking_point_id == talking_point.id}.each{|r| talking_point.rating_votes[r.rating-1] = r.count.to_i }
    talking_point.my_rating = rating.to_i
    
    return talking_point
    
  end
  
  def o_type
    14 #type for talking point
  end
  
  def type_text
    'talking point acceptable rating' #type for talking point
  end
  
  
end
