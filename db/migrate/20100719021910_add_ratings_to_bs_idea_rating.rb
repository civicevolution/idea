class AddRatingsToBsIdeaRating < ActiveRecord::Migration
  def self.up
    add_column :bs_idea_ratings, :rating, :int, :default => 0
    remove_column :bs_idea_ratings, :up
    remove_column :bs_idea_ratings, :down
  end

  def self.down
    remove_column :bs_idea_ratings, :rating
    add_column :bs_idea_ratings, :up, :int
    add_column :bs_idea_ratings, :down, :int
  end
end
