class CreateChatMessages < ActiveRecord::Migration
  def self.up
    create_table :chat_messages do |t|
      t.integer :chat_session_id, :null => false
      t.integer :member_id, :null => false
      t.text :text, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :chat_messages
  end
end
