class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.integer :comment_id
      t.integer :member_id
      t.string :title
      t.text :description
      t.text :url
      t.integer :file_id
      t.string :file_name
      t.integer :size
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :resources
  end
end
