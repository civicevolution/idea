class CreateChatActiveSessions < ActiveRecord::Migration
  def self.up
    create_table :chat_active_sessions do |t|
      t.integer :chat_session_id, :null => false
      t.integer :o_type, :null => false
      t.integer :o_id, :null => false
      t.integer :team_id, :null => false
      t.string :status, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :chat_active_sessions
  end
end
