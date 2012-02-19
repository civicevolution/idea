class AddFieldsToLiveTalkingPoints < ActiveRecord::Migration
  def self.up
    add_column :live_talking_points, :id_letter, :string
    add_column :live_talking_points, :target, :string
    add_column :live_talking_points, :type, :string
    add_column :live_talking_points, :pos_votes, :integer
    add_column :live_talking_points, :neg_votes, :integer
    add_column :live_talking_points, :status, :string
  end

  def self.down
    remove_column :live_talking_points, :status
    remove_column :live_talking_points, :neg_votes
    remove_column :live_talking_points, :pos_votes
    remove_column :live_talking_points, :type
    remove_column :live_talking_points, :target
    remove_column :live_talking_points, :id_letter
  end
end
