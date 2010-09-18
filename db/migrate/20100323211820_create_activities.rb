class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :member_id
      t.integer :team_id
      t.string :action
      t.text :cookie
      t.text :user_agent

      t.timestamps
    end
    execute "ALTER TABLE activities ADD COLUMN ip inet"
  end

  def self.down
    drop_table :activities
  end
end
