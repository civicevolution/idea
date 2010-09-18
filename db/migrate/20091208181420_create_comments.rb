class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :member_id, :null => false
      t.boolean :anonymous, :null => false, :default => false
      t.string :status, :null => false
      t.text :text, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
