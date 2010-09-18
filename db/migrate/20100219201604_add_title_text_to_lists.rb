class AddTitleTextToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :title, :string, :null => false
    add_column :lists, :text, :text, :null => false
  end

  def self.down
    remove_column :lists, :text
    remove_column :lists, :title
  end
end
