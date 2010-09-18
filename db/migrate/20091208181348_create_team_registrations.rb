class CreateTeamRegistrations < ActiveRecord::Migration
  def self.up
    create_table :team_registrations do |t|
      t.integer :team_id, :null => false
      t.integer :member_id, :null => false
      t.string :status, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :team_registrations
  end
end
