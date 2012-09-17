class Idea < ActiveRecord::Base
  attr_accessible :is_theme, :member_id, :order_id, :parent_id, :question_id, :team_id, :text, :version, :visible
  
  belongs_to :question
  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 20', :order => 'id desc', :include => :author
  has_many :idea_ratings, select: 'member_id, rating'

  attr_accessor :current_member
  
  def siblings_count
    if self.parent_id.nil?
      Idea.where("question_id = ? AND parent_id is null", self.question_id).count
    else
      ActiveRecord::Base.connection.select_value( %Q| select count(*) FROM ideas where parent_id = #{self.parent_id} and is_theme = false| ).to_i
    end
  end
  
  def o_type
    20 #type for Idea
  end
  def type_text
    'idea' #type for Idea
  end
  
end
