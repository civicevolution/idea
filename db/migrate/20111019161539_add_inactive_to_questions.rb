class AddInactiveToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :inactive, :boolean, :default => false
  end

  def self.down
    remove_column :questions, :inactive
  end
end
