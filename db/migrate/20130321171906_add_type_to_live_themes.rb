class AddTypeToLiveThemes < ActiveRecord::Migration
  class LiveThemes < ActiveRecord::Base
  end

  def change
    add_column :live_themes, :theme_type, :integer, default: 0

    LiveThemes.reset_column_information
    
    LiveTheme.joins("LEFT OUTER JOIN live_sessions ON live_themes.live_session_id = live_sessions.id WHERE session_type = 'macrotheme'").each do |theme|
      theme.update_column(:theme_type, 1)
    end
    
    LiveTheme.joins("LEFT OUTER JOIN live_sessions ON live_themes.live_session_id = live_sessions.id WHERE session_type = 'microtheme'").each do |theme|
      theme.update_column(:theme_type, 0)
    end
    
    
  end
end
