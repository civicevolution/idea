class CreateCheckListItems < ActiveRecord::Migration
  def self.up
    create_table :check_list_items do |t|
      t.integer :team_id, :null=> false
      t.string :title, :null=> false
      t.text :description
      t.integer :par_id, :null=> false
      t.integer :order, :null=> false
      t.boolean :completed, :default=>false
      t.boolean :request_details, :default=>false
      t.text :details
      t.integer :discussion, :default=>0

      t.timestamps
    end
  end

  def self.down
    drop_table :check_list_items
  end
end
