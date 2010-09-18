class RenameMembersPwdToHashedPwd < ActiveRecord::Migration
  def self.up
    rename_column :members, :pwd, :hashed_pwd
  end

  def self.down
    rename_column :members, :hashed_pwd, :pwd
  end
end
