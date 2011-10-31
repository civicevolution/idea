class CreateLiveNodes < ActiveRecord::Migration
  def self.up
    create_table :live_nodes do |t|
      t.integer :live_event_id
      t.string :name
      t.text :description
      t.integer :parent_id
      t.string :username
      t.string :password

      t.timestamps
    end
  end

  def self.down
    drop_table :live_nodes
  end
end
