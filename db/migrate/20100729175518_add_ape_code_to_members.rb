class AddApeCodeToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :ape_code, :string, :limit => 14, :unique => true
    execute "ALTER TABLE ONLY members ADD CONSTRAINT unique_members_ape_code UNIQUE (ape_code)"
  end

  def self.down
    execute "ALTER TABLE ONLY members DROP CONSTRAINT unique_members_ape_code"
    remove_column :members, :ape_code
  end
end
