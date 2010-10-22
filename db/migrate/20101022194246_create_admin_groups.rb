class CreateAdminGroups < ActiveRecord::Migration
  def self.up
    create_table :admin_groups do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_groups
  end
end
