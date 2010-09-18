class DropResourceColumnFileId < ActiveRecord::Migration
  def self.up
    execute 'ALTER TABLE resources DROP COLUMN file_id'
  end

  def self.down
    add_column :resources, :file_id, :integer
  end
end
