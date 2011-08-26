class AddContentTypeAndIdToContentReports < ActiveRecord::Migration
  def self.up
    add_column :content_reports, :content_type, :string
    add_column :content_reports, :content_id, :integer
  end

  def self.down
    remove_column :content_reports, :content_id
    remove_column :content_reports, :content_type
  end
end
