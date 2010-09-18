class DropTextAndVerFromChatSessions < ActiveRecord::Migration
  def self.up
     remove_column :chat_sessions, :text
     remove_column :chat_sessions, :ver
  end

  def self.down
    add_column :chat_sessions, :ver, :integer, :null => false, :default => 0
    add_column :chat_sessions, :text, :text, :null => false
  end
end
