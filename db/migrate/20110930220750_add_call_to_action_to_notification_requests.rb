class AddCallToActionToNotificationRequests < ActiveRecord::Migration
  def self.up
    add_column :notification_requests, :call_to_action, :bool
  end

  def self.down
    remove_column :notification_requests, :call_to_action
  end
end
