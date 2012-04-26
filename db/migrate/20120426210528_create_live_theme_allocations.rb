class CreateLiveThemeAllocations < ActiveRecord::Migration
  def self.up
    create_table :live_theme_allocations do |t|
      t.integer :session_id
      t.integer :theme_id
      t.integer :table_id
      t.integer :voter_id
      t.integer :points

      t.timestamps
    end
  end

  def self.down
    drop_table :live_theme_allocations
  end
end
