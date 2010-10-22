class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.integer :member_id
      t.integer :admin_group_id
      t.integer :initiative_id

      t.timestamps
    end
  end

  def self.down
    drop_table :admins
  end
end
