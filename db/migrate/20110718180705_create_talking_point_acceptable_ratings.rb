class CreateTalkingPointAcceptableRatings < ActiveRecord::Migration
  def self.up
    create_table :talking_point_acceptable_ratings do |t|
      t.integer :talking_point_id
      t.integer :member_id
      t.integer :rating

      t.timestamps
    end
  end

  def self.down
    drop_table :talking_point_acceptable_ratings
  end
end
