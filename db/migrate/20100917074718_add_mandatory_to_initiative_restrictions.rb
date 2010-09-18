class AddMandatoryToInitiativeRestrictions < ActiveRecord::Migration
  def self.up
    add_column :initiative_restrictions, :mandatory, :boolean, :default=>false
  end

  def self.down
    remove_column :initiative_restrictions, :mandatory
  end
end
