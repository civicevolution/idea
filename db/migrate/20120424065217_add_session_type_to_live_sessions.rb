class AddSessionTypeToLiveSessions < ActiveRecord::Migration
  def self.up
    add_column :live_sessions, :session_type, :string
  end

  def self.down
    remove_column :live_sessions, :session_type
  end
end
