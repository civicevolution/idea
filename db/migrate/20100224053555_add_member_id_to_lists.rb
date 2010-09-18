class AddMemberIdToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :member_id, :integer, :null => false
  end

  def self.down
    remove_column :lists, :member_id    
  end
end
