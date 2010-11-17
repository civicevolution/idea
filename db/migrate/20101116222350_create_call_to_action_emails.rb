class CreateCallToActionEmails < ActiveRecord::Migration
  def self.up
    create_table :call_to_action_emails do |t|
      t.string :scenario
      t.integer :version
      t.string :subject
      t.text :message
      t.string :data
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :call_to_action_emails
  end
end
