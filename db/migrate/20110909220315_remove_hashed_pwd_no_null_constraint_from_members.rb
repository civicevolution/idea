class RemoveHashedPwdNoNullConstraintFromMembers < ActiveRecord::Migration
  def self.up
    change_column :members, :hashed_pwd, :string, :null => true
  end

  def self.down
    change_column :members, :hashed_pwd, :string, :null => false
  end
end
