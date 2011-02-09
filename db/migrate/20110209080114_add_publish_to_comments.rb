class AddPublishToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :publish, :boolean
  end

  def self.down
    remove_column :comments, :publish
  end
end
