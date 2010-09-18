class DropPrimaryFromTeamRegistrations < ActiveRecord::Migration
  def self.up
        remove_column :team_registrations, :primary
  end

  def self.down
    add_column :team_registrations, :primary, :boolean, :default=>true
  end
end
