class AddRoleToIdeas < ActiveRecord::Migration
  class Idea < ActiveRecord::Base
  end
  
  def change
    add_column :ideas, :role, :integer
    add_column :ideas, :aux_id, :integer
    Idea.reset_column_information
    Idea.where(is_theme: false).each do |idea|
      idea.update_column(:role, 1)
    end
    Idea.where(is_theme: true).each do |idea|
      idea.update_column(:role, 2)
    end
  end
end
