class AddIdeaAndAnswerCriteriaToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :idea_criteria, :string, :default=>'5..1000'
    add_column :questions, :answer_criteria, :string, :default=>'5..1500'
  end

  def self.down
    remove_column :questions, :answer_criteria
    remove_column :questions, :idea_criteria
  end
end
