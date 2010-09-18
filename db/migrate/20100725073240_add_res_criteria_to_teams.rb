class AddResCriteriaToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :res_criteria, :string, :default=>'5..500'
  end

  def self.down
    remove_column :teams, :res_criteria
  end
end
