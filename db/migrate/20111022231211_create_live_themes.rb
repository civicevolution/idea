class CreateLiveThemes < ActiveRecord::Migration
  def self.up
    create_table :live_themes do |t|
      t.integer :live_session_id
      t.integer :themer_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :live_themes
  end
end
