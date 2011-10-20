class CreateParticipantStats < ActiveRecord::Migration
  def self.up
    create_table :participant_stats do |t|
      t.integer :member_id
      t.integer :team_id
      t.integer :proposal_views, :default=>0
      t.integer :question_views, :default=>0
      t.integer :friend_invites, :default=>0
      t.integer :following, :default=>0
      t.boolean :endorse, :default=>false
      t.integer :talking_points, :default=>0
      t.integer :talking_point_edits, :default=>0
      t.integer :talking_point_ratings, :default=>0
      t.integer :talking_point_preferences, :default=>0
      t.integer :comments, :default=>0
      t.integer :content_reports, :default=>0
      t.integer :points_total, :default=>0
      t.integer :points_days1, :default=>0
      t.integer :points_days3, :default=>0
      t.integer :points_days7, :default=>0
      t.integer :points_days14, :default=>0
      t.integer :points_days28, :default=>0
      t.integer :points_days90, :default=>0
      t.timestamp :last_visit

      t.timestamps
    end
  end

  def self.down
    drop_table :participant_stats
  end
end
