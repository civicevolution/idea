class AddScenarioToCallToActionQueue < ActiveRecord::Migration
  def self.up
    add_column :call_to_action_queues, :scenario, :string
  end

  def self.down
    remove_column :call_to_action_queues, :scenario
  end
end
