class CreateTalkingPointPreferences < ActiveRecord::Migration
  def self.up
    create_table :talking_point_preferences do |t|
      t.integer :talking_point_id
      t.integer :member_id

      t.timestamps
    end
  end

  def self.down
    drop_table :talking_point_preferences
  end
end
