class CreateListItems < ActiveRecord::Migration
  def self.up
    create_table :list_items do |t|
      t.integer :id
      t.integer :list_id
      t.integer :order
      t.integer :member_id
      t.boolean :anonymous, :default => false
      t.text :text
      t.integer :ver

      t.timestamps
    end
  end

  def self.down
    drop_table :list_items
  end
end
