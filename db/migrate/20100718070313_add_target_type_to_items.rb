class AddTargetTypeToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :target_type, :int, :default => 0
  end

  def self.down
    remove_column :items, :target_type
  end
end
