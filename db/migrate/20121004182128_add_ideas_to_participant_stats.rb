class AddIdeasToParticipantStats < ActiveRecord::Migration
  class ParticipantStat < ActiveRecord::Base
  end
  
  def change
    add_column :participant_stats, :ideas, :integer, :default => 0
    add_column :participant_stats, :idea_ratings, :integer, :default => 0
    ParticipantStat.reset_column_information
    ParticipantStat.all.each do |stat|
      stat.update_column(:ideas, 0)
      stat.update_column(:idea_ratings, 0)      
    end
    
  end
end
