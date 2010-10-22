class CreateAdminPrivileges < ActiveRecord::Migration
  def self.up
    create_table :admin_privileges do |t|
      t.integer :admin_group_id
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_privileges
  end
end
