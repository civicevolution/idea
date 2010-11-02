class AddScenarioToMemberLookupCode < ActiveRecord::Migration
  def self.up
    add_column :member_lookup_codes, :scenario, :string
  end

  def self.down
    remove_column :member_lookup_codes, :scenario
  end
end
