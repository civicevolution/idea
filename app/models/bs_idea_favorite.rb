class BsIdeaFavorite < ActiveRecord::Base
  
  validate :check_init_access
  
  attr_accessible :bs_idea_id, :member_id, :favorite
  
  attr_accessor :team_id
  attr_accessor :member
  
  def check_init_access
    self.team_id = ActiveRecord::Base.connection.select_value( "SELECT team_id FROM bs_ideas where id = #{self.bs_idea_id}" )
    # this is access check for the idea page version
    allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add_to_base("Sorry, you do not have permission to favorite a brainstorming idea.") 
      return false
    end
  end
  
  def after_save
    # get the team_id
    bs_idea = BsIdea.find(self.bs_idea_id)
    self.team_id = bs_idea.team_id
  end
  
end
