class CreateNotificationRequests < ActiveRecord::Migration
  def self.up
    create_table :notification_requests do |t|
      t.integer :team_id
      t.integer :member_id
      t.integer :report_type
      t.integer :report_format
      t.boolean :immediate
      t.column ("dow_to_run", "integer[]")
      t.column ("hour_to_run", "integer[]")
      t.column ("match_queue", "text[]")

      t.timestamps
    end
  end

  def self.down
    drop_table :notification_requests
  end
end
