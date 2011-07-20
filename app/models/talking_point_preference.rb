class TalkingPointPreference < ActiveRecord::Base
  
  #scope :sums, lambda { select('talking_point_id, count(member_id)').group('talking_point_id') }
	scope :sums, lambda { |ids| select('talking_point_id, count(member_id)').group('talking_point_id').where(:talking_point_id => ids) }
	
	scope :my_votes, lambda { |ids,member_id| select('talking_point_id').where("talking_point_id IN(?) AND member_id = ?", ids, member_id) }

end
