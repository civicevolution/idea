class CreateLiveThemingSessions < ActiveRecord::Migration
  def self.up
    create_table :live_theming_sessions do |t|
      t.integer :themer_id
      t.integer :live_session_id
      t.text :theme_group_ids
      t.text :unthemed_ids

      t.timestamps
    end
  end

  def self.down
    drop_table :live_theming_sessions
  end
end
