class AddJugIdToLiveNodes < ActiveRecord::Migration
  def self.up
    add_column :live_nodes, :jug_id, :string
  end

  def self.down
    remove_column :live_nodes, :jug_id
  end
end
