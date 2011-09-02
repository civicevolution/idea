class TalkingPointPreference < ActiveRecord::Base
  
  #scope :sums, lambda { select('talking_point_id, count(member_id)').group('talking_point_id') }
	scope :sums, lambda { |ids| select('talking_point_id, count(member_id)').group('talking_point_id').where(:talking_point_id => ids) }
	
	scope :my_votes, lambda { |ids,member_id| select('talking_point_id').where("talking_point_id IN(?) AND member_id = ?", ids, member_id) }
	
  attr_accessor :member
  
	before_validation :check_initiative_restrictions
  
  def check_initiative_restrictions
    #logger.debug "TalkingPointPreference.check_initiative_restrictions"
    allowed,message = InitiativeRestriction.allow_actionX({:talking_point_id=>self.talking_point_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to prefer this talking point.") 
      return false
    end
    true
  end

  def self.preferred_talking_points( question_id, member_id )
    TalkingPoint.select('talking_points.id, text').
      joins(:talking_point_preferences).
      where('talking_point_preferences.member_id = ? AND question_id = ?', member_id, question_id).
      order('talking_point_preferences.id DESC')
      
    #TalkingPoint.find_by_sql(%Q|select tp2.id, tp2.text 
    #from talking_points tp1, talking_points tp2, talking_point_preferences tpp 
    #where tp1.id = #{talking_point_id} 
    #and tp1.question_id = tp2.question_id 
    #and tpp.talking_point_id = tp2.id 
    #AND tpp.member_id = #{member_id}
    #order by tpp.id DESC|)
  end

  def self.update_preferred_talking_points( question_id, talking_point_ids, member_id )
    # I get the list of ids I want to retain as favorites and I need to delete the rest for this question
    current_ids = TalkingPoint.select('talking_points.id').
      joins(:talking_point_preferences).
      where('talking_point_preferences.member_id = ? AND question_id = ?', member_id, question_id).map(&:id)

    talking_point_ids.map!{|i| i.to_i}
    
    ids_to_add = talking_point_ids - current_ids

    if ids_to_add.size > 0
      logger.debug "ids_to_add.inspect: #{ids_to_add.inspect}"
      ids_to_add.each{ |id| TalkingPointPreference.create( :member_id=> member_id, :talking_point_id => id)  }
    end
    
    ids_to_remove = current_ids - talking_point_ids
    logger.debug "ids_to_remove.inspect: #{ids_to_remove.inspect}"
    logger.debug("remove these ids: #{ids_to_remove.inspect}")
    if ids_to_remove.size > 0
      TalkingPointPreference.delete_all(:talking_point_id=> ids_to_remove, :member_id => 1)
    end
  end



end
