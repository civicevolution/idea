class AddInitIdToPreliminaryParticipantActivities < ActiveRecord::Migration
  def self.up
    add_column :preliminary_participant_activities, :init_id, :integer
  end

  def self.down
    remove_column :preliminary_participant_activities, :init_id
  end
end
