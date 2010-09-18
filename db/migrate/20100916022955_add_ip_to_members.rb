class AddIpToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :ip, :inet
  end

  def self.down
    remove_column :members, :ip
  end
end
