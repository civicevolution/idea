class Idea < ActiveRecord::Base
  attr_accessible :is_theme, :member_id, :order_id, :parent_id, :question_id, :team_id, :text, :version, :visible
  
  belongs_to :question
  
end
