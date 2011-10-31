class CreateLiveEvents < ActiveRecord::Migration
  def self.up
    create_table :live_events do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :live_events
  end
end
