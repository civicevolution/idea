class CreateProposalIdeas < ActiveRecord::Migration
  def self.up
    create_table :proposal_ideas do |t|
      t.integer :initiative_id, :null => false
      t.integer :member_id, :null => false
      t.boolean :accept_guidelines, :null => false
      t.text :title, :null => false
      t.text :text, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :proposal_ideas
  end
end
