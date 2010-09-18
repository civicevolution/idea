class CreateHelpRequests < ActiveRecord::Migration
  def self.up
    create_table :help_requests do |t|
      t.integer :client_details_id, :null=> false
      t.string :name
      t.string :email
      t.integer :category, :null=> false
      t.text :message, :null=> false

      t.timestamps
    end
  end

  def self.down
    drop_table :help_requests
  end
end
