class CreateProposalSubmits < ActiveRecord::Migration
  def self.up
    create_table :proposal_submits do |t|
      t.integer :team_id
      t.integer :member_id
      t.string :submit_type
      t.string :name
      t.string :email
      t.string :phone
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :proposal_submits
  end
end
