class CreateClientDetails < ActiveRecord::Migration
  def self.up
    create_table :client_details do |t|
      t.string :session_id
      t.column("ip", :inet) # this works beautifully
      t.integer :member_id
      t.integer :team_id
      t.string :url
      t.text :user_agent
      t.text :error_log
      t.integer :load_time

      t.timestamps
    end
  end

  def self.down
    drop_table :client_details
  end
end
