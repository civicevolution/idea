class AddAnonymousToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :anonymous, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :questions, :anonymous
  end
end
