class CreateFormItems < ActiveRecord::Migration
  def self.up
    create_table :form_items do |t|
      t.integer :form_id, :null=> false
      t.string :name, :null=> false
      t.text :value, :null=> false

      t.timestamps
    end
  end

  def self.down
    drop_table :form_items
  end
end
