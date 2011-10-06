class CreateParticipationEvents < ActiveRecord::Migration
  def self.up
    create_table :participation_events do |t|
      t.integer :initiative_id
      t.integer :team_id
      t.integer :question_id
      t.integer :item_type
      t.integer :item_id
      t.integer :member_id
      t.integer :event_id
      t.integer :points

      t.timestamps
    end
  end

  def self.down
    drop_table :participation_events
  end
end
