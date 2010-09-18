class CreateAnswerRatings < ActiveRecord::Migration
  def self.up
    create_table :answer_ratings do |t|
      t.integer :answer_id, :null => false
      t.integer :member_id, :null => false
      t.integer :rating, :default => 0, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :answer_ratings
  end
end
