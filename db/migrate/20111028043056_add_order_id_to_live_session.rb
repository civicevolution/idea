class AddOrderIdToLiveSession < ActiveRecord::Migration
  def self.up
    add_column :live_sessions, :order_id, :integer
  end

  def self.down
    remove_column :live_sessions, :order_id
  end
end
