class AddCuratedTalkingPointIdsToQuestions < ActiveRecord::Migration
  def self.up
    add_column :questions, :curated_tp_ids, :string
    add_column :questions, :auto_curated, :boolean, :default => true   
    Question.update_all("auto_curated = true") 
  end

  def self.down
    remove_column :questions, :curated_tp_ids
    remove_column :questions, :auto_curated
  end
end
