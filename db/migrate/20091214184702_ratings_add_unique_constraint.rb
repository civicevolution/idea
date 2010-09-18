class RatingsAddUniqueConstraint < ActiveRecord::Migration
  def self.up
     execute "ALTER TABLE ONLY ratings ADD CONSTRAINT unique_item_id_member_id UNIQUE (item_id,member_id)"
  end

  def self.down
    execute "ALTER TABLE ONLY ratings DROP CONSTRAINT unique_item_id_member_id"
  end
end