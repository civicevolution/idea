class AddThemesToParticipantStats < ActiveRecord::Migration
  class ParticipantStat < ActiveRecord::Base
  end

  def change
    add_column :participant_stats, :themes, :integer, :default => 0
    add_column :participant_stats, :theme_ratings, :integer, :default => 0
    ParticipantStat.reset_column_information
    ParticipantStat.all.each do |stat|
      stat.update_column(:themes, 0)
      stat.update_column(:theme_ratings, 0)      
    end
    
  end
end
