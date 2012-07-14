class BsIdeaRating < ActiveRecord::Base
  
  has_one :bs_idea
  #has_many :bs_idea_rating, :dependent => :destroy
  
  validate_on_create :check_team_access
  validate_on_update :check_item_edit_access
    
  #before_destroy :check_item_delete_access
  
  attr_accessible :idea_id, :member_id, :rating
  
  attr_accessor :team_id
  #attr_accessor :question_id
  
  def self.idea_ratings (idea_id, mem_id)
    BsIdeaRating.find_by_sql( [ %q|SELECT AVG(rating) AS average, 
      COUNT(rating) AS count,
      (SELECT rating FROM bs_idea_ratings WHERE member_id = ? AND idea_id = ?) AS my_vote
      FROM bs_idea_ratings 
      WHERE idea_id = ?|, mem_id, idea_id, idea_id] );
  end
  
  
  def check_team_access
    logger.debug "check_team_access, for BsIdeaRating idea_id = #{self.idea_id}"
    #self.question_id = BsIdea.find(self.idea_id).question_id
    #@team = Member.find_by_id(self.member_id).teams.find_by_id( Item.find_by_o_id_and_o_type(self.question_id,1).team_id )
    @team = Member.find_by_id(self.member_id).teams.find_by_id( BsIdea.find(self.idea_id).team_id )
    raise TeamAccessDeniedError, "In BsIdeaRating.check_team_access BsIdea idea_id = #{self.idea_id}" if @team.nil?
    self.team_id = @team.id # this will be used to send APE message
    @team
  end
  
  def check_item_edit_access
    #self.question_id = BsIdea.find(self.idea_id).question_id
    #@team = Member.find_by_id(self.member_id).teams.find_by_id( Item.find_by_o_id_and_o_type(self.question_id,1).team_id )
    @team = Member.find_by_id(self.member_id).teams.find_by_id( BsIdea.find(self.idea_id).team_id )
    raise TeamAccessDeniedError, "In BsIdeaRating.check_team_access BsIdea idea_id = #{self.idea_id}" if @team.nil?
    self.team_id = @team.id # this will be used to send APE message
    @team
  end
  
    
end
