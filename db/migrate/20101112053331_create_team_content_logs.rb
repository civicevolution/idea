class CreateTeamContentLogs < ActiveRecord::Migration
  def self.up
    create_table :team_content_logs do |t|
      t.integer :team_id
      t.integer :member_id
      t.integer :o_type
      t.integer :o_id
      t.integer :par_member_id
      t.boolean :processed

      t.timestamps
    end
  end

  def self.down
    drop_table :team_content_logs
  end
end
