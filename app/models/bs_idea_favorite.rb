class BsIdeaFavorite < ActiveRecord::Base
  
  attr_accessor :team_id
  
  def after_save
    # get the team_id
    bs_idea = BsIdea.find(self.bs_idea_id)
    self.team_id = bs_idea.team_id
  end
  
end
