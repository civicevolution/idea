class CreateIdeaRatings < ActiveRecord::Migration
  def change
    create_table :idea_ratings do |t|
      t.integer :idea_id
      t.integer :member_id
      t.integer :rating

      t.timestamps
    end
  end
end
