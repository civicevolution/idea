class DropUniqueMemberLookupCodeFromMemberLookupCode < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE ONLY member_lookup_codes DROP CONSTRAINT unique_member_lookup_code_member_id"    
  end

  def self.down
    execute "ALTER TABLE ONLY member_lookup_codes ADD CONSTRAINT unique_member_lookup_code_member_id UNIQUE (member_id)"    
  end
end
