class AddDeletedToListItems < ActiveRecord::Migration
  def self.up
    add_column :list_items, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :list_items, :deleted
  end
end
