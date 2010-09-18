class CreateComRatings < ActiveRecord::Migration
  def self.up
    create_table :com_ratings do |t|
      t.integer :comment_id
      t.integer :member_id
      t.integer :up
      t.integer :down

      t.timestamps
    end
  end

  def self.down
    drop_table :com_ratings
  end
end
