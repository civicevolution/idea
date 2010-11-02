class CreateMemberLookupCodeLogs < ActiveRecord::Migration
  def self.up
    drop_table :member_lookup_code_logs
    create_table :member_lookup_code_logs do |t|
      t.column("code", :uuid) # this works beautifully
      t.integer :member_id
      t.string :scenario
      t.integer :target_id
      t.string :target_url

      t.timestamps
    end
  end

  def self.down
    drop_table :member_lookup_code_logs
  end
end
