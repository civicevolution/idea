class CreateBsIdeaRatings < ActiveRecord::Migration
  def self.up
    create_table :bs_idea_ratings do |t|
      t.integer :idea_id
      t.integer :member_id
      t.integer :up, :default => 0
      t.integer :down, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :bs_idea_ratings
  end
end
