class ChangeThumbsRatingsToUpDown < ActiveRecord::Migration
  def self.up
    remove_column :thumbs_ratings, :rating
    add_column :thumbs_ratings, :up, :integer, :default => 0
    add_column :thumbs_ratings, :down, :integer, :default => 0
  end

  def self.down
    add_column :thumbs_ratings, :rating, :integer
    remove_column :thumbs_ratings, :up
    remove_column :thumbs_ratings, :down
  end
end
