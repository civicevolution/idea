class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.integer :item_id, :null => false
      t.integer :member_id, :null => false
      t.decimal :rating, :null => false, :precision => 3, :scale => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :ratings
  end
end
