class AddExtendedChecklistToDefaultAnswers < ActiveRecord::Migration
  def self.up
    add_column :default_answers, :extended_checklist, :text
  end

  def self.down
    remove_column :default_answers, :extended_checklist
  end
end
