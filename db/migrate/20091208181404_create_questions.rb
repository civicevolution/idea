class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :member_id, :null => false
      t.string :status, :null => false, :default => 'ok'
      t.text :text, :null => false
      t.integer :num_answers, :null => false, :default => 1000

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
