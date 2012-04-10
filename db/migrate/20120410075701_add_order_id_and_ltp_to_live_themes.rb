class AddOrderIdAndLtpToLiveThemes < ActiveRecord::Migration
  def self.up
    add_column :live_themes, :order_id, :integer
    add_column :live_themes, :live_talking_point_ids, :text
    add_column :live_themes, :example_ids, :text
  end

  def self.down
    remove_column :live_themes, :example_ids
    remove_column :live_themes, :live_talking_point_ids
    remove_column :live_themes, :order_id
  end
end
