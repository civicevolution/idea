class AddParentTypeAndIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :parent_type, :integer
    add_column :comments, :parent_id, :integer
  end

  def self.down
    remove_column :comments, :parent_id
    remove_column :comments, :parent_type
  end
end
