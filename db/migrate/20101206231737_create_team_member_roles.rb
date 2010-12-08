class CreateTeamMemberRoles < ActiveRecord::Migration
  def self.up
    create_table :team_member_roles do |t|
      t.integer :team_id
      t.integer :member_id
      t.integer :role_id

      t.timestamps
    end
    execute "ALTER TABLE ONLY team_member_roles ADD CONSTRAINT tma_unique_member_id_role_id_team_id UNIQUE (member_id,role_id,team_id)"
  end

  def self.down
    drop_table :team_member_roles
  end
end
