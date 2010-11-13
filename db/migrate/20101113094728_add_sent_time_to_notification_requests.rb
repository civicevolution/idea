class AddSentTimeToNotificationRequests < ActiveRecord::Migration
  def self.up
    add_column :notification_requests, :sent_time, :datetime
  end

  def self.down
    remove_column :notification_requests, :sent_time
  end
end
