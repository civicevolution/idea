class AddSibIdToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :sib_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :items, :sib_id
  end
end
