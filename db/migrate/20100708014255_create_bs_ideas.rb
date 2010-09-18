class CreateBsIdeas < ActiveRecord::Migration
  def self.up
    create_table :bs_ideas do |t|
      t.integer :question_id
      t.integer :member_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :bs_ideas
  end
end
