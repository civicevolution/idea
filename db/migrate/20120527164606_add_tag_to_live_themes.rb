class AddTagToLiveThemes < ActiveRecord::Migration
  def self.up
    add_column :live_themes, :tag, :string, :default => 'default'
    LiveTheme.update_all("tag = 'default'")
  end

  def self.down
    remove_column :live_themes, :tag
  end
end
