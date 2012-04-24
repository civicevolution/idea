class AddEventCodeToLiveEvents < ActiveRecord::Migration
  def self.up
    add_column :live_events, :event_code, :string
  end

  def self.down
    remove_column :live_events, :event_code
  end
end
