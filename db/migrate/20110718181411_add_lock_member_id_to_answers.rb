class AddLockMemberIdToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :lock_member_id, :integer
  end

  def self.down
    remove_column :answers, :lock_member_id
  end
end
