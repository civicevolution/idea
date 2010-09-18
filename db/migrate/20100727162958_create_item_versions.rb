class CreateItemVersions < ActiveRecord::Migration
  def self.up
    create_table :item_versions do |t|
      t.integer :item_id
      t.integer :item_type
      t.integer :ver
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :item_versions
  end
end
