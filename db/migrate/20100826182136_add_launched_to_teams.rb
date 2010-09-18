class AddLaunchedToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :launched, :boolean, :null=> false, :default=> false
  end

  def self.down
    remove_column :teams, :launched
  end
end
