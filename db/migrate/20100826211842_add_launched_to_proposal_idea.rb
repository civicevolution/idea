class AddLaunchedToProposalIdea < ActiveRecord::Migration
  def self.up
    add_column :proposal_ideas, :launched, :boolean, :null=> false, :default=> false 
  end

  def self.down
    remove_column :proposal_ideas, :launched
  end
end
