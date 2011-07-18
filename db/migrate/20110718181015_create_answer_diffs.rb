class CreateAnswerDiffs < ActiveRecord::Migration
  def self.up
    create_table :answer_diffs do |t|
      t.integer :answer_id
      t.integer :member_id
      t.integer :version
      t.binary :diff
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :answer_diffs
  end
end
