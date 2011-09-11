class CreatePreliminaryParticipantActivities < ActiveRecord::Migration
  def self.up
    create_table :preliminary_participant_activities do |t|
      t.string :email
      t.text :flash_params

      t.timestamps
    end
  end

  def self.down
    drop_table :preliminary_participant_activities
  end
end
