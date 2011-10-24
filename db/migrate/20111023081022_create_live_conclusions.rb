class CreateLiveConclusions < ActiveRecord::Migration
  def self.up
    create_table :live_conclusions do |t|
      t.integer :live_session_id
      t.integer :themer_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :live_conclusions
  end
end
