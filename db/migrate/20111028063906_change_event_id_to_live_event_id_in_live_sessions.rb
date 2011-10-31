class ChangeEventIdToLiveEventIdInLiveSessions < ActiveRecord::Migration
  def self.up
    rename_column :live_sessions, :event_id, :live_event_id
  end

  def self.down
    rename_column :live_sessions, :live_event_id, :event_id
  end
end
