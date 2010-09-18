class CreateItemLocks < ActiveRecord::Migration
  def self.up
    create_table :item_locks do |t|
      t.integer :o_id, :null => false
      t.integer :o_type, :null => false
      t.integer :member_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :item_locks
  end
end
