class ComRating < ActiveRecord::Base

  has_one :comment
  
  validate :check_rating_access
  
  attr_accessor :team_id
  
  def self.com_ratings (com_id,mem_id)
    ComRating.find_by_sql( [ %q|
      SELECT SUM(up) AS up,
      SUM(down) AS down,
      (SELECT CASE WHEN up = 1 THEN 1 ELSE -1 END FROM com_ratings WHERE member_id = ? AND comment_id = ?) AS my_vote
      FROM com_ratings
      WHERE comment_id = ?|, mem_id, com_id, com_id] );
  end
  
  def check_rating_access
    logger.debug "check_rating_access, comment_id: #{self.comment_id}"
    @team = Member.find_by_id(self.member_id).teams.find_by_id( Item.find_by_o_id_and_o_type(self.comment_id,3).team_id )
    raise TeamAccessDeniedError, "In check_team_access for ComRating for comment_id: #{self.comment_id}" if @team.nil?
    self.team_id = @team.id # this will be used to construct the item record
    #logger.debug "Member of team #{@team.title}"
    @team
  end  
  
  
end
