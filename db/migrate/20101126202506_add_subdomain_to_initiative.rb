class AddSubdomainToInitiative < ActiveRecord::Migration
  def self.up
    add_column :initiatives, :domain, :string, :null=>false, :default=>'civicevolution.org'
  end

  def self.down
    remove_column :initiatives, :domain
  end
end
