class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.integer :id
      t.integer :format, :default => 1
      t.boolean :anonymous, :default => true
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :lists
  end
end
