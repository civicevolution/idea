class AnswerRating < ActiveRecord::Base
  
  has_one :answer
  #has_many :bs_idea_rating, :dependent => :destroy
  
  validate :check_team_access
  #validate_on_create :check_team_access
  #validate_on_update :check_item_edit_access
    
  #before_destroy :check_item_delete_access

  attr_accessor :team_id
  attr_accessor :member
  #attr_accessor :question_id
  
  
  def self.answer_ratings (ans_id, mem_id)
    AnswerRating.find_by_sql( [ %q|SELECT AVG(rating) AS average, 
      COUNT(rating) AS count,
      (SELECT rating FROM answer_ratings WHERE member_id = ? AND answer_id = ?) AS my_vote
      FROM answer_ratings 
      WHERE answer_id = ?|, mem_id, ans_id, ans_id] );
  end
  
  def check_team_access
    logger.debug "AnswerRating check_team_access member: #{self.member.inspect}"
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:answer_id=>self.answer_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add(:base, "Sorry, you do not have permission to rate this answer.") 
        return false
      end
      return
    end
    
    
    #logger.debug "check_team_access, for AnswerRating answer_id = #{self.answer_id}"
    @team = Member.find_by_id(self.member_id).teams.find_by_id( Answer.find(self.answer_id).team_id )
    raise TeamAccessDeniedError, "In AnswerRating.check_team_access Answer answer_id = #{self.answer_id}" if @team.nil?
    self.team_id = @team.id # this will be used to send APE message
    @team
  end
  
  def check_item_edit_access
    @team = Member.find_by_id(self.member_id).teams.find_by_id( Answer.find(self.answer_id).team_id );
    raise TeamAccessDeniedError, "In AnswerRating.check_item_edit_access Answer answer_id = #{self.answer_id}" if @team.nil?
    self.team_id = @team.id # this will be used to send APE message
    @team
  end
  


end
