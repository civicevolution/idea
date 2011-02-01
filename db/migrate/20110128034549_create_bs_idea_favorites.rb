class CreateBsIdeaFavorites < ActiveRecord::Migration
  def self.up
    create_table :bs_idea_favorites do |t|
      t.integer :bs_idea_id
      t.integer :member_id
      t.boolean :favorite

      t.timestamps
    end
  end

  def self.down
    drop_table :bs_idea_favorites
  end
end
