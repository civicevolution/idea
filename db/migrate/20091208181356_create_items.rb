class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :team_id, :null => false
      t.integer :o_id, :null => false
      t.integer :o_type, :null => false
      t.integer :par_id, :null => false
      t.integer :order, :null => false
      t.string :ancestors, :default => '0'

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
