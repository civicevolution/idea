class Idea < ActiveRecord::Base
  attr_accessible :is_theme, :member_id, :order_id, :parent_id, :question_id, :team_id, :text, :version, :visible, :current_member

  belongs_to :team
  belongs_to :question
  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 20', :order => 'id desc', :include => :author
  has_many :idea_ratings, select: 'member_id, rating'
  has_many :ideas, foreign_key: 'parent_id', order: 'id asc'
  has_many :siblings, class_name: 'Idea', finder_sql: proc { 
    if self.is_theme
      %Q|SELECT * FROM ideas WHERE parent_id = #{self.parent_id} and is_theme = true ORDER BY order_id ASC| 
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
  
  before_validation :check_initiative_restrictions, :on=>:create
  
  validates :text, length: { 
    minimum: 10,
    too_short: "must be at least 2 characters",
    maximum: 200,
    too_long: "must have at most %{count} characters"
  }

  def check_initiative_restrictions
    allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:parent_id=>self.question_id, :parent_type => 1}, 'contribute_to_proposal', self.current_member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to add an idea.") 
      return false
    end
    true
  end
  
  def self.reorder_siblings( idea_id, ordered_ids )
    ctr = 0
    order_string = ordered_ids.map{|o| "(#{ctr+=1},#{o})" }.join(',')
    
    sql = %Q|UPDATE ideas SET parent_id = #{idea_id}, order_id = new_order_id FROM ( SELECT * FROM (VALUES #{order_string}) vals (new_order_id,idea_id)	) t WHERE id = t.idea_id|
    logger.debug "Use sql: #{sql}"
    ActiveRecord::Base.connection.update_sql(sql)
  end
  
  def o_type
    20 #type for Idea
  end
  def type_text
    'idea' #type for Idea
  end
  
end
