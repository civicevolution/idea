class CreateQuestionLoadTimes < ActiveRecord::Migration
  def self.up
    create_table :question_load_times do |t|
      t.integer :question_id
      t.integer :member_id

      t.timestamps
    end
  end

  def self.down
    drop_table :question_load_times
  end
end
