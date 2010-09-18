class ChangeResourceColumnNamesForPaperclip < ActiveRecord::Migration
  def self.up
     rename_column :resources, :file_name, :resource_file_name
     rename_column :resources, :type, :resource_content_type
     rename_column :resources, :size, :resource_file_size
  end

  def self.down
    rename_column :resources, :resource_file_name, :file_name
    rename_column :resources, :resource_content_type, :type
    rename_column :resources, :resource_file_size, :size
  end
end
