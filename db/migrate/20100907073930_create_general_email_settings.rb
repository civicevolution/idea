class CreateGeneralEmailSettings < ActiveRecord::Migration
  def self.up
    create_table :general_email_settings do |t|
      t.integer :member_id, :null=> false
      t.boolean :accept_broadcast_messages, :default=> false
      t.boolean :forward_messages, :default=> false

      t.timestamps
    end
    execute "ALTER TABLE ONLY general_email_settings ADD CONSTRAINT unique_general_email_settings_member_id UNIQUE (member_id)"
  end

  def self.down
    drop_table :general_email_settings
  end
end
