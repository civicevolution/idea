class CreateLiveSessions < ActiveRecord::Migration
  def self.up
    create_table :live_sessions do |t|
      t.integer :event_id
      t.text :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :live_sessions
  end
end
