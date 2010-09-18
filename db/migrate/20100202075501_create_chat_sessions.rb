class CreateChatSessions < ActiveRecord::Migration
  def self.up
    create_table :chat_sessions do |t|
      t.integer :member_id, :null => false
      t.text :text, :null => false
      t.integer :ver, :null => false, :default => 0
      t.string :status, :null => false, :default => 'ok'

      t.timestamps
    end
  end

  def self.down
    drop_table :chat_sessions
  end
end
