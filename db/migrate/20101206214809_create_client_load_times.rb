class CreateClientLoadTimes < ActiveRecord::Migration
  def self.up
    create_table :client_load_times do |t|
      t.column("ip", :inet) # this works beautifully
      t.string :session_id
      t.integer :team_id
      t.integer :member_id
      t.integer :page_load
      t.integer :ape_load
      t.integer :all_init
      t.text :user_agent
      t.integer :height
      t.integer :width

      t.timestamps
    end
  end

  def self.down
    drop_table :client_load_times
  end
end
