class CreateInitiativeRestrictions < ActiveRecord::Migration
  def self.up
    create_table :initiative_restrictions do |t|
      t.integer :initiative_id, :null=> false
      t.string :action, :null=> false
      t.string :restriction, :null=> false
      t.string :arg, :null=> false

      t.timestamps
    end
  end

  def self.down
    drop_table :initiative_restrictions
  end
end
