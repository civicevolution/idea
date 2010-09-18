class CreateThumbsRatings < ActiveRecord::Migration
  def self.up
    create_table :thumbs_ratings do |t|
      t.integer :item_id
      t.integer :member_id
      t.integer :rating

      t.timestamps
    end
    execute "ALTER TABLE ONLY thumbs_ratings ADD CONSTRAINT unique_thumbs_ratings_item_id_member_id UNIQUE (item_id,member_id)"
  end

  def self.down
    drop_table :thumbs_ratings
  end
end
