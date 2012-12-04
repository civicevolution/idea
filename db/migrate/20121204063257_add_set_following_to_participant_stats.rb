class AddSetFollowingToParticipantStats < ActiveRecord::Migration
  class ParticipantStats < ActiveRecord::Base
  end
  
  def change
    add_column :participant_stats, :set_following, :boolean
    ParticipantStats.reset_column_information
    ParticipantStats.where('following = 0').each do |stat|
      stat.update_column(:set_following, false)
    end
    ParticipantStats.where('following > 0').each do |stat|
      stat.update_column(:set_following, true)
    end
    
  end
end
