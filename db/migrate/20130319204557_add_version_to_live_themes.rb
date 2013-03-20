class AddVersionToLiveThemes < ActiveRecord::Migration
  class LiveThemes < ActiveRecord::Base
  end
  
  def change
    add_column :live_themes, :version, :integer, default: 0
    
    LiveThemes.reset_column_information
    LiveThemes.all.each do |live_theme|
      live_theme.update_column(:version, 1)
    end
    
  end
  
end
