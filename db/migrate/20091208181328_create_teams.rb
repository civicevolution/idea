class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.integer :initiative_id, :null => false
      t.integer :org_id, :null => false
      t.string :title, :null => false
      t.text :problem_statement, :null => false
      t.text :solution_statement, :null => false
      t.string :status
      t.integer :min_members
      t.integer :max_members
      t.string :timezone
      t.string :lang
      t.integer :config_id
      t.boolean :public_face
      t.integer :public_face_rating_threshold
      t.boolean :archived
      t.string :signup_mode
      t.string :join_test
      t.string :join_code
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
    execute "SELECT setval('teams_id_seq', 10000, false);"
  end

  def self.down
    drop_table :teams
  end
end
