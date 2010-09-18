class AddTeamIdAndQuestionIdToAnswers < ActiveRecord::Migration
  def self.up
    add_column :answers, :team_id, :int, :default => 0, :null => false
    add_column :answers, :question_id, :int, :default => 0, :null => false
  end

  def self.down
    remove_column :answers, :question_id
    remove_column :answers, :team_id
  end
end
