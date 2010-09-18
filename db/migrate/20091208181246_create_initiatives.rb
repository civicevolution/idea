class CreateInitiatives < ActiveRecord::Migration
  def self.up
    create_table :initiatives do |t|
      t.string :title, :null => false
      t.text :description, :null => false
      t.integer :min_members, :null => false, :default => 1
      t.integer :max_members, :null => false, :default => 25
      t.integer :max_teams_per_member, :null => false, :default => 1000
      t.boolean :limit_access
      t.string :access_code
      t.boolean :can_propose_team, :default => true
      t.boolean :prescreen_proposals, :default => false
      t.string :timezone
      t.string :lang, :default => 'us'
      t.integer :config_id
      t.boolean :public_face
      t.integer :public_face_rating_threshold, :default => 3
      t.string :join_test
      t.boolean :approve_join
      t.boolean :send_invites
      t.boolean :approve_invites
      t.string :admin_groups
      t.string :country
      t.string :state
      t.string :county
      t.string :city

      t.timestamps
    end
  end

  def self.down
    drop_table :initiatives
  end
end
