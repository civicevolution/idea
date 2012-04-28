class ChangeStartingTimeColumnInLiveSessions < ActiveRecord::Migration
  def self.up
     change_column :live_sessions, :starting_time, :time
  end

  def self.down
     change_column :live_sessions, :starting_time, :timestamp
  end
end
