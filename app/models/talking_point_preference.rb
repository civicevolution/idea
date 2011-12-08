class TalkingPointPreference < ActiveRecord::Base
  
  belongs_to :talking_point
  
  #scope :sums, lambda { select('talking_point_id, count(member_id)').group('talking_point_id') }
	scope :sums, lambda { |ids| select('talking_point_id, count(member_id)').group('talking_point_id').where(:talking_point_id => ids) }
	
	scope :my_votes, lambda { |ids,member_id| select('talking_point_id').where("talking_point_id IN(?) AND member_id = ?", ids, member_id) }
	
  attr_accessor :member
  
	before_validation :check_initiative_restrictions
	
	before_validation :verify_less_than_allowed_limit, :on => :create
	after_save :check_auto_curate
	
	def verify_less_than_allowed_limit
	  @question = Question.find_by_sql(%Q|SELECT * FROM questions 
	    WHERE id = (SELECT question_id FROM talking_points WHERE id = #{self.talking_point_id})|)[0]
	  preferences = TalkingPointPreference.where(:member_id => member.id, :talking_point_id => TalkingPoint.sibling_talking_points(self.talking_point_id).map(&:id)).count
	  if preferences >= @question.talking_point_preferences.to_i
      errors.add(:base, "Sorry, you have already selected the maximum number of preferred talking points for this question.") 
    end
  end
  
  def check_initiative_restrictions
    self.member = Member.find(self.member_id) if self.id.nil?
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
  
  def self.update_question_preferred_talking_points( question_id, talking_point_ids, member )
    # I get the list of ids I want to retain as favorites and I need to delete the rest for this question
    current_ids = TalkingPoint.select('talking_points.id').
      joins(:talking_point_preferences).
      where('talking_point_preferences.member_id = ? AND question_id = ?', member.id, question_id).map(&:id)

    talking_point_ids.map!{|i| i.to_i}
    
    ids_to_add = talking_point_ids - current_ids

    if ids_to_add.size > 0
      #logger.debug "ids_to_add.inspect: #{ids_to_add.inspect}"
      ids_to_add.each{ |id| TalkingPointPreference.find_or_create_by_member_id_and_talking_point_id(member.id, id) }
    end
    
    ids_to_remove = current_ids - talking_point_ids
    logger.debug "ids_to_remove.inspect: #{ids_to_remove.inspect}"
    logger.debug("remove these ids: #{ids_to_remove.inspect}")
    if ids_to_remove.size > 0
      TalkingPointPreference.delete_all(:talking_point_id=> ids_to_remove, :member_id => member.id)
    end
    
    @question = Question.find( question_id )
    TalkingPoint.get_and_assign_stats( @question, @question.talking_points, member )
    
    @question.auto_curate_talking_points() if @question.auto_curated
    
    return @question
  end

  def self.update_preferred_talking_points( question_id, selected_ids, tp_ids, member )
    selected_ids.map!{|i| i.to_i}
    deselected_ids = tp_ids.map!{|i| i.to_i} - selected_ids

    if deselected_ids.size > 0
      TalkingPointPreference.delete_all(:talking_point_id=> deselected_ids, :member_id => member.id)
    end

    # I need to check if the user will be adding too many preferred items and not save them if this is the case
    current_ids = TalkingPoint.select('talking_points.id').
      joins(:talking_point_preferences).
      where('talking_point_preferences.member_id = ? AND question_id = ?', member.id, question_id).map(&:id)

    if (selected_ids + current_ids).uniq.size <= 5
      if selected_ids.size > 0
        #logger.debug "selected_ids.inspect: #{selected_ids.inspect}"
        selected_ids.each{ |id| TalkingPointPreference.find_or_create_by_member_id_and_talking_point_id(member.id, id)  }
      end
      return []
    else
      logger.debug "User is selecting too many talking point preferences"
      return selected_ids - current_ids
    end
    
  end

  def o_type
    15 #type for talking point preference
  end
  
  def type_text
    'talking point preference' #type for talking point
  end
  
protected
  def check_auto_curate
    if @question.auto_curated
      @question.auto_curate_talking_points()
    end
  end
  
  
end
