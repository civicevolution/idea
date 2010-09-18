class AddTeamIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :team_id, :int
  end

  def self.down
    remove_column :comments, :team_id
  end
end
