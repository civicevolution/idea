class CreateMemberLookupCodes < ActiveRecord::Migration
  def self.up
    create_table :member_lookup_codes do |t|
      t.string :code,  :unique => true, :null => false
      t.integer :member_id, :unique => true, :null => false

      t.timestamps
    end
    execute "ALTER TABLE ONLY member_lookup_codes ADD CONSTRAINT unique_member_lookup_codes_code UNIQUE (code)"
    execute "ALTER TABLE ONLY member_lookup_codes ADD CONSTRAINT unique_member_lookup_code_member_id UNIQUE (member_id)"    
  end

  def self.down
    drop_table :member_lookup_codes
  end
end