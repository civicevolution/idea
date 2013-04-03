class AddTestModeToLiveEvents < ActiveRecord::Migration
  class LiveEvents < ActiveRecord::Base
  end
  
  def change
    add_column :live_events, :test_mode, :bool, default: true
    
    LiveEvents.reset_column_information
    LiveEvents.all.each do |live_event|
      live_event.update_column(:test_mode, false)
    end
    
    
  end
end
