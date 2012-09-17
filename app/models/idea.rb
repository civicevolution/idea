class Idea < ActiveRecord::Base
  attr_accessible :is_theme, :member_id, :order_id, :parent_id, :question_id, :team_id, :text, :version, :visible

  belongs_to :team
  belongs_to :question
  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 20', :order => 'id desc', :include => :author
  has_many :idea_ratings, select: 'member_id, rating'
  has_many :ideas, foreign_key: 'parent_id', order: 'id asc'
  has_many :siblings, class_name: 'Idea', finder_sql: proc { 
    if self.is_theme
      %Q|SELECT * FROM ideas WHERE parent_id = #{self.parent_id} and is_theme = true ORDER BY id DESC| 
    elsif self.parent_id.nil?
      %Q|SELECT * FROM ideas WHERE question_id = #{self.question_id} AND parent_id IS null ORDER BY id DESC|
    else
      %Q|SELECT * FROM ideas WHERE parent_id = #{self.parent_id} and is_theme = false ORDER BY id DESC| 
    end  
    },
    counter_sql: proc { 
      if self.is_theme
        %Q|SELECT COUNT( * ) FROM ideas WHERE parent_id = #{self.parent_id} and is_theme = true| 
      elsif self.parent_id.nil?
        %Q|SELECT COUNT( * ) FROM ideas WHERE question_id = #{self.question_id} AND parent_id IS null|
      else
        %Q|SELECT COUNT( * ) FROM ideas WHERE parent_id = #{self.parent_id} and is_theme = false| 
      end  
      }
    
      

  attr_accessor :current_member
  
  def o_type
    20 #type for Idea
  end
  def type_text
    'idea' #type for Idea
  end
  
end
