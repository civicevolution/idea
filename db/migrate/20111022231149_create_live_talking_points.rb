class CreateLiveTalkingPoints < ActiveRecord::Migration
  def self.up
    create_table :live_talking_points do |t|
      t.integer :live_session_id
      t.integer :group_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :live_talking_points
  end
end
