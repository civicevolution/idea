class AddPublishedDurationStartToLiveSessions < ActiveRecord::Migration
  def self.up
    add_column :live_sessions, :published, :boolean
    add_column :live_sessions, :starting_time, :datetime
    add_column :live_sessions, :duration, :integer
    LiveSession.update_all("published = false") 
  end

  def self.down
    remove_column :live_sessions, :duration
    remove_column :live_sessions, :starting_time
    remove_column :live_sessions, :published
  end
end
