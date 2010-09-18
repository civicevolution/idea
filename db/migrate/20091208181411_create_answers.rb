class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer :member_id, :null => false
      t.boolean :anonymous, :null => false, :default => false
      t.string :status, :null => false, :default => 'ok'
      t.text :text, :null => false
      t.integer :ver, :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
