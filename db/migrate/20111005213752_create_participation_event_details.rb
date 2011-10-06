class CreateParticipationEventDetails < ActiveRecord::Migration
  def self.up
    create_table :participation_event_details do |t|
      t.integer :id
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :participation_event_details
  end
end
