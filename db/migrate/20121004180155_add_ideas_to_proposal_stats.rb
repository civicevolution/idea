class AddIdeasToProposalStats < ActiveRecord::Migration
  class ProposalStat < ActiveRecord::Base
  end
  
  def change
    add_column :proposal_stats, :ideas, :integer, :default => 0
    add_column :proposal_stats, :idea_ratings, :integer, :default => 0
    ProposalStat.reset_column_information
    ProposalStat.all.each do |stat|
      stat.update_column(:ideas, 0)
      stat.update_column(:idea_ratings, 0)      
    end
    
  end
end
