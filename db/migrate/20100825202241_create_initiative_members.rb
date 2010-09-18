class CreateInitiativeMembers < ActiveRecord::Migration
  def self.up
    create_table :initiative_members do |t|
      t.integer :initiative_id, :null => false
      t.integer :member_id, :null => false
      t.boolean :accept_tos, :null => false
      t.integer :member_category, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :initiative_members
  end
end
