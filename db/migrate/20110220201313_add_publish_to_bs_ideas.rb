class AddPublishToBsIdeas < ActiveRecord::Migration
  def self.up
    add_column :bs_ideas, :publish, :boolean
  end

  def self.down
    remove_column :bs_ideas, :publish
  end
end
