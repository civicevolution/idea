class RemoveTypeIdUseItemIdForChatActiveSessions < ActiveRecord::Migration
  def self.up
    remove_column :chat_active_sessions, :o_type
    remove_column :chat_active_sessions, :o_id
    add_column :chat_active_sessions, :item_id, :integer, :null => false
  end

  def self.down
    add_column :chat_active_sessions, :o_type, :integer, :null => false
    add_column :chat_active_sessions, :o_id, :integer, :null => false
    remove_column :chat_active_sessions, :item_id
  end
end
