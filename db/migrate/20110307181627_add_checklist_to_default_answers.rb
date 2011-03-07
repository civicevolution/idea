class AddChecklistToDefaultAnswers < ActiveRecord::Migration
  def self.up
    add_column :default_answers, :checklist, :text
  end

  def self.down
    remove_column :default_answers, :checklist
  end
end
