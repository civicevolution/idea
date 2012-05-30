class CreateLiveSessionData < ActiveRecord::Migration
  def self.up
    create_table :live_session_data do |t|
      t.integer :live_session_id
      t.boolean :primary_field
      t.integer :io_type
      t.integer :source_session_id
      t.string :label
      t.string :tag, :default => 'default'
      t.integer :qty
      t.integer :chars
      t.integer :height

      t.timestamps
    end
  end

  def self.down
    drop_table :live_session_data
  end
end
