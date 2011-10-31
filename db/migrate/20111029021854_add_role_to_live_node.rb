class AddRoleToLiveNode < ActiveRecord::Migration
  def self.up
    add_column :live_nodes, :role, :string
  end

  def self.down
    remove_column :live_nodes, :role
  end
end
