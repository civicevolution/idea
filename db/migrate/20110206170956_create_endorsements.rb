class CreateEndorsements < ActiveRecord::Migration
  def self.up
    create_table :endorsements do |t|
      t.integer :team_id
      t.integer :member_id
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :endorsements
  end
end
