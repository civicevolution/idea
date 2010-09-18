class AddPrimaryAndAccessDetailsToTeamRegistrations < ActiveRecord::Migration
  def self.up
    add_column :team_registrations, :primary, :boolean, :default=>true
    add_column :team_registrations, :access_details, :string, :default=>'full'
  end

  def self.down
    remove_column :team_registrations, :access_details
    remove_column :team_registrations, :primary
  end
end
