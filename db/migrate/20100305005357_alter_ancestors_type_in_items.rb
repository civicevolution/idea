class AlterAncestorsTypeInItems < ActiveRecord::Migration
  def self.up
    remove_column :items, :ancestors
    execute "ALTER TABLE items ADD COLUMN ancestors integer[]"
  end

  def self.down
    remove_column :items, :ancestors
    add_column :items, :ancestors, :string 
  end
end
