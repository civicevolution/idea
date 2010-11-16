class CreateCallToActionEmailsSents < ActiveRecord::Migration
  def self.up
    create_table :call_to_action_emails_sents do |t|
      t.integer :member_id
      t.integer :member_lookup_code_id
      t.text :scenario
      t.integer :version
      t.integer :team_id
      t.datetime :opened_email
      t.datetime :visit_site

      t.timestamps
    end
  end

  def self.down
    drop_table :call_to_action_emails_sents
  end
end
