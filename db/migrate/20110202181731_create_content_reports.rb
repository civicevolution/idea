class CreateContentReports < ActiveRecord::Migration
  def self.up
    create_table :content_reports do |t|
      t.integer :item_id
      t.integer :member_id
      t.string :sender_name
      t.string :sender_email
      t.string :report_type
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :content_reports
  end
end
