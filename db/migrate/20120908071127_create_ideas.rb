class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.text :text
      t.boolean :is_theme
      t.integer :member_id
      t.integer :team_id
      t.integer :question_id
      t.integer :parent_id
      t.integer :order_id
      t.boolean :visible
      t.integer :version

      t.timestamps
    end
  end
end
