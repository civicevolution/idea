class AddTeamIdAndTalkingPointFieldsToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :team_id, :integer
    add_column :questions, :order_id, :integer
    add_column :questions, :talking_point_criteria, :string
    add_column :questions, :talking_point_preferences, :string
  end

  def self.down
    remove_column :questions, :talking_point_preferences
    remove_column :questions, :talking_point_criteria
    remove_column :questions, :order_id
    remove_column :questions, :team_id
  end
end
