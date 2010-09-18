class AddTeamIdToBsIdeas < ActiveRecord::Migration
  def self.up
    add_column :bs_ideas, :team_id, :int
  end

  def self.down
    remove_column :bs_ideas, :team_id
  end
end
