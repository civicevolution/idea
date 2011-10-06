class CreateInvites < ActiveRecord::Migration
  def self.up
    create_table :invites do |t|
      t.integer :member_id
      t.integer :initiative_id
      t.integer :team_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :_ilc

      t.timestamps
    end
  end

  def self.down
    drop_table :invites
  end
end
