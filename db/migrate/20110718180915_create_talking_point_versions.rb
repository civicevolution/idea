class CreateTalkingPointVersions < ActiveRecord::Migration
  def self.up
    create_table :talking_point_versions do |t|
      t.integer :talking_point_id
      t.integer :member_id
      t.integer :version
      t.string :text
      t.integer :lock_member_id

      t.timestamps
    end
  end

  def self.down
    drop_table :talking_point_versions
  end
end
