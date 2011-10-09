class CreateProposalStats < ActiveRecord::Migration
  def self.up
    create_table :proposal_stats do |t|
      t.integer :team_id
      t.integer :proposal_views, :default => 0
      t.integer :question_views, :default => 0
      t.integer :participants, :default => 0
      t.integer :friend_invites, :default => 0
      t.integer :followers, :default => 0
      t.integer :endorsements, :default => 0
      t.integer :talking_points, :default => 0
      t.integer :talking_point_edits, :default => 0
      t.integer :talking_point_ratings, :default => 0
      t.integer :talking_point_preferences, :default => 0
      t.integer :comments, :default => 0
      t.integer :points, :default => 0
      t.integer :content_reports, :default => 0
      t.integer :proposal_views_base, :default => 0
      t.integer :question_views_base, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :proposal_stats
  end
end
