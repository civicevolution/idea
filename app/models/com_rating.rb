class ComRating < ActiveRecord::Base

  has_one :comment
  
  validate :check_rating_access
  
  attr_accessor :team_id
  attr_accessor :member
  
  
  def self.com_ratings (com_id,mem_id)
    ComRating.find_by_sql( [ %q|
      SELECT SUM(up) AS up,
      SUM(down) AS down,
      (SELECT CASE WHEN up = 1 THEN 1 ELSE -1 END FROM com_ratings WHERE member_id = ? AND comment_id = ?) AS my_vote
      FROM com_ratings
      WHERE comment_id = ?|, mem_id, com_id, com_id] );
  end
  
  def check_rating_access
    
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:comment_id=>self.comment_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add_to_base("Sorry, you do not have permission to rate this comment.") 
        return false
      end
      return
    end
    
    #logger.debug "check_rating_access, comment_id: #{self.comment_id}"
    rated_item = Item.find_by_o_id_and_o_type(self.comment_id,3)
    self.team_id = rated_item.team_id
    is_team_member = !( TeamRegistration.find_by_member_id_and_team_id(self.member_id, self.team_id).nil? )
    # return as ok if user is a team member or parent is the public discussion
    return if is_team_member
    
    #logger.debug "check for pub anc self.team_id: #{self.team_id}"
    # determine if this is under a public discussion, is any ancestor, type 11?
    #logger.debug "rated_item: #{rated_item.inspect}"
    pub_par_item = Item.find(
      :all,
      :select=>'id',
      :conditions=> {:team_id=>self.team_id , :o_type=>11, :id => rated_item.ancestors.split(/[^\d]/).map { |s| s.to_i }.uniq }
    )
    #logger.debug "pub_par_item.size: #{pub_par_item.size}"
    
    if pub_par_item.size == 0
      errors.add_to_base("This discussion is private and you must be a team member to rate it.") 
      return false
    end
    
  end  
  
  
end
