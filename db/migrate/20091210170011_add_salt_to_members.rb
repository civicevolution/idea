class AddSaltToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :salt, :string
  end

  def self.down
    remove_column :members, :salt
  end
end
