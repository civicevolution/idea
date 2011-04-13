class AddEmailOkToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :email_ok, :boolean, :default=> true
  end

  def self.down
    remove_column :members, :email_ok
  end
end
