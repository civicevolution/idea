class AddSourceSessionIdToLiveSessions < ActiveRecord::Migration
  def self.up
    add_column :live_sessions, :source_session_id, :integer
  end

  def self.down
    remove_column :live_sessions, :source_session_id
  end
end
