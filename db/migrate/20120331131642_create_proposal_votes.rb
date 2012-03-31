class CreateProposalVotes < ActiveRecord::Migration
  def self.up
    create_table :proposal_votes do |t|
      t.integer :initiative_id
      t.integer :member_id
      t.integer :team_id
      t.integer :points

      t.timestamps
    end
  end

  def self.down
    drop_table :proposal_votes
  end
end
