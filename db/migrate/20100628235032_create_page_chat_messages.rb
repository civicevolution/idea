class CreatePageChatMessages < ActiveRecord::Migration
  def self.up
    create_table :page_chat_messages do |t|
      t.integer :page_id
      t.integer :member_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :page_chat_messages
  end
end
