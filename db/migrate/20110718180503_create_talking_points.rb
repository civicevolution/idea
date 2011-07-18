class CreateTalkingPoints < ActiveRecord::Migration
  def self.up
    create_table :talking_points do |t|
      t.integer :question_id
      t.integer :member_id
      t.integer :version
      t.string :text

      t.timestamps
    end
  end

  def self.down
    drop_table :talking_points
  end
end
