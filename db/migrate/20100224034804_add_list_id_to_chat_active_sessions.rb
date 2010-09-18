class AddListIdToChatActiveSessions < ActiveRecord::Migration
  def self.up
    add_column :chat_active_sessions, :list_id, :integer, :null => false
  end

  def self.down
    remove_column :chat_active_sessions, :list_id
  end
end
