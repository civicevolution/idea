class AddVisibleToLiveThemes < ActiveRecord::Migration
  def self.up
    add_column :live_themes, :visible, :boolean
    LiveTheme.update_all("visible = true") 
  end

  def self.down
    remove_column :live_themes, :visible
  end
end
