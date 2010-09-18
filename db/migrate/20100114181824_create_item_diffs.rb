class CreateItemDiffs < ActiveRecord::Migration
  def self.up
    create_table :item_diffs do |t|
      t.integer :o_id, :null => false
      t.integer :o_type, :null => false
      t.integer :ver, :null => false
      t.integer :member_id, :null => false
      t.boolean :anonymous, :null => false
      t.binary :diff, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :item_diffs
  end
end
