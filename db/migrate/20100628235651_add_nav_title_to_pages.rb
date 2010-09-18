class AddNavTitleToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :nav_title, :string
  end

  def self.down
    remove_column :pages, :nav_title
  end
end
