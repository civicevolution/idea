class AddOrderAndVisibilityToTalkingPoints < ActiveRecord::Migration
  def self.up
    add_column :talking_points, :order_id, :integer, :default => 0
    add_column :talking_points, :visible, :boolean, :default => true
    TalkingPoint.update_all ["order_id = ?, visible = ?", 1, true]
  end

  def self.down
    remove_column :talking_points, :visible
    remove_column :talking_points, :order_id
  end
end
