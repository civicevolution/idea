class AddTagToLiveThemingSessions < ActiveRecord::Migration
  def self.up
    add_column :live_theming_sessions, :tag, :string, :default => 'default'
    LiveThemingSession.update_all("tag = 'default'")
  end

  def self.down
    remove_column :live_theming_sessions, :tag
  end
end
