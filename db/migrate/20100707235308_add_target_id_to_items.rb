class AddTargetIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :target_id, :int, :default => 0
  end

  def self.down
    remove_column :items, :target_id
  end
end
