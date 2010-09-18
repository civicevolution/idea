class AddComCriteriaToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :com_criteria, :string, :default=>'5..1500'
  end

  def self.down
    remove_column :teams, :com_criteria
  end
end
