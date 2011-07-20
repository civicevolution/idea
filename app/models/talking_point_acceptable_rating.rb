class TalkingPointAcceptableRating < ActiveRecord::Base
  
  scope :sums, lambda { select('talking_point_id, rating, count(member_id)').group('talking_point_id, rating') }
  
  scope :my_votes, lambda { |ids,member_id| select('talking_point_id, rating').where("talking_point_id IN(?) AND member_id = ?", ids, member_id) }
  
end
