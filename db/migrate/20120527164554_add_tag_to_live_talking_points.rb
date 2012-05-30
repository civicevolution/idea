class AddTagToLiveTalkingPoints < ActiveRecord::Migration
  def self.up
    add_column :live_talking_points, :tag, :string, :default => 'default'
    LiveTalkingPoint.update_all("tag = 'default'")
  end

  def self.down
    remove_column :live_talking_points, :tag
  end
end
