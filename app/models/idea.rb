class Idea < ActiveRecord::Base
  attr_accessible :is_theme, :member_id, :order_id, :parent_id, :question_id, :team_id, :text, :version, :visible
  
  belongs_to :question
  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 20', :order => 'id desc', :include => :author


  def o_type
    20 #type for Idea
  end
  def type_text
    'idea' #type for Idea
  end
  
end
