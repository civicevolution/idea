class AddVerToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :ver, :integer, :null => false, :default => '0'
  end

  def self.down
    remove_column :questions, :ver
  end
end
