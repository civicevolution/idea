class AddDefaultAnswerIdToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :default_answer_id, :integer
  end

  def self.down
    remove_column :questions, :default_answer_id
  end
end
