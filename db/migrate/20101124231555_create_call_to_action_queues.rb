class CreateCallToActionQueues < ActiveRecord::Migration
  def self.up
    create_table :call_to_action_queues do |t|
      t.integer :team_id, :null=>false, :default=>0
      t.integer :member_id, :null=> false
      t.boolean :sent, :default=> false

      t.timestamps
    end
    execute "ALTER TABLE ONLY call_to_action_queues ADD CONSTRAINT cta_unique_member_id_team_id UNIQUE (member_id,team_id)"
  end

  def self.down
    drop_table :call_to_action_queues
  end
end
