class CreateDefaultAnswers < ActiveRecord::Migration
  def self.up
    create_table :default_answers do |t|
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :default_answers
  end
end
