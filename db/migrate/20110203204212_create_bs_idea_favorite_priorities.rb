class CreateBsIdeaFavoritePriorities < ActiveRecord::Migration
  def self.up
    create_table :bs_idea_favorite_priorities do |t|
      t.integer :question_id
      t.integer :member_id
      t.column ("priority", "int[]")

      t.timestamps
    end
  end

  def self.down
    drop_table :bs_idea_favorite_priorities
  end
end