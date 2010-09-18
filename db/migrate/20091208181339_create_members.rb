class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string :email, :null => false
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.integer :pic_id, :null => false
      t.integer :init_id, :null => false
      t.string :pwd, :null => false
      t.boolean :confirmed, :default => false
      t.string :city
      t.string :state
      t.string :country
      t.string :location
      t.string :access_code

      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
