class AddGroupIdToLiveSessions < ActiveRecord::Migration
  def self.up
    add_column :live_sessions, :group_id, :integer
  end

  def self.down
    remove_column :live_sessions, :group_id
  end
end
