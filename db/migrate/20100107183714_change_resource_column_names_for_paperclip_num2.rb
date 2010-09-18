class ChangeResourceColumnNamesForPaperclipNum2 < ActiveRecord::Migration
  def self.up
     rename_column :resources, :url, :link_url
  end

  def self.down
    rename_column :resources, :link_url, :url
  end
end