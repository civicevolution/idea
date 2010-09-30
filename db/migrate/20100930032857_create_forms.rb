class CreateForms < ActiveRecord::Migration
  def self.up
    create_table :forms do |t|
      t.integer :member_id, :null=> false
      t.string :form_name, :null=> false

      t.timestamps
    end
  end

  def self.down
    drop_table :forms
  end
end
