class AddThemesToProposalStats < ActiveRecord::Migration
  class ProposalStat < ActiveRecord::Base
  end
  
  def change
    add_column :proposal_stats, :themes, :integer, :default => 0
    add_column :proposal_stats, :theme_ratings, :integer, :default => 0
    ProposalStat.reset_column_information
    ProposalStat.all.each do |stat|
      stat.update_column(:themes, 0)
      stat.update_column(:theme_ratings, 0)      
    end
    
  end
end
