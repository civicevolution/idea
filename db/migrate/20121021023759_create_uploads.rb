class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.integer :team_id
      t.integer :question_id
      t.integer :par_type
      t.integer :par_id
      t.integer :order_id
      t.integer :member_id
      t.integer :version
      t.text :description
      
      t.has_attached_file :attachment

      t.timestamps
    end
  end
end
