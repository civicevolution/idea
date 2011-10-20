class AddIntervalSumsToProposalStats < ActiveRecord::Migration
  def self.up
    remove_column :proposal_stats, :points
    add_column :proposal_stats, :points_total, :integer, :default=>0
    add_column :proposal_stats, :points_days1, :integer, :default=>0
    add_column :proposal_stats, :points_days3, :integer, :default=>0
    add_column :proposal_stats, :points_days7, :integer, :default=>0
    add_column :proposal_stats, :points_days14, :integer, :default=>0
    add_column :proposal_stats, :points_days28, :integer, :default=>0
    add_column :proposal_stats, :points_days90, :integer, :default=>0
  end

  def self.down
    remove_column :proposal_stats, :points_days90
    remove_column :proposal_stats, :points_days28
    remove_column :proposal_stats, :points_days14
    remove_column :proposal_stats, :points_days7
    remove_column :proposal_stats, :points_days3
    remove_column :proposal_stats, :points_days1
    remove_column :proposal_stats, :points_total
    add_column :proposal_stats, :points, :integer
  end
end
