class MemberIdFromChatSessions < ActiveRecord::Migration
  def self.up
    remove_column :chat_sessions, :member_id
  end

  def self.down
    add_column :chat_sessions, :member_id, :integer, :null => false
  end
end
