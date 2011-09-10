class CreateEmailLookupCodes < ActiveRecord::Migration
  def self.up
    create_table :email_lookup_codes do |t|
      t.string :code
      t.string :email

      t.timestamps
    end
    execute "ALTER TABLE ONLY email_lookup_codes ADD CONSTRAINT unique_email_lookup_code UNIQUE (code)"    
  end

  def self.down
    drop_table :email_lookup_codes
  end
end
