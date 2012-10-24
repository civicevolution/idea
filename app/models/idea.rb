class Idea < ActiveRecord::Base
  attr_accessible :member_id, :order_id, :parent_id, :question_id, :team_id, :text, :version, :visible, :member, :role, :aux_id
  
  after_find do |idea|
    if idea.role == 4
      begin
        idea.question_id = idea.questions[0].id
      rescue
        idea.question_id = 0
      end
    end
  end  
  

  belongs_to :team
  belongs_to :question, class_name: 'Idea', foreign_key: 'question_id', primary_key: 'id', conditions: 'role = 3'
  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 20', :order => 'id desc', :include => :author
  has_many :idea_ratings, select: 'member_id, rating'
  has_many :ideas, foreign_key: 'parent_id', order: 'id asc'
  has_many :theme_ideas, class_name: 'Idea', foreign_key: 'parent_id', order: 'order_id asc'
    
  has_many :themes, class_name: 'Idea', foreign_key: 'question_id', conditions: 'role = 2', order: 'order_id asc'
  has_one :prompt, :class_name => 'DefaultAnswer', :foreign_key => 'id',  :primary_key => 'aux_id'
  has_many :unthemed_ideas, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'role = 1 AND parent_id IS NULL', :order => 'order_id asc'
  has_many :parked_ideas, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'role = 1 AND parent_id = 0', :order => 'order_id asc'
  has_many :themed_ideas, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'role = 1 AND parent_id IS NOT NULL AND parent_id != 0', :order => 'order_id asc'

  has_many :questions, class_name: 'Idea', conditions: 'role = 3', foreign_key: 'parent_id', primary_key: 'team_id', order: 'order_id asc'

  has_many :siblings, class_name: 'Idea', finder_sql: proc { 
    if self.role == 2
      %Q|SELECT * FROM ideas WHERE parent_id = #{self.parent_id} and role = 2 ORDER BY order_id ASC| 
    elsif self.role == 3
      %Q|SELECT * FROM ideas WHERE parent_id = #{self.parent_id} and role = 3 ORDER BY order_id ASC| 
    elsif self.parent_id.nil?
      %Q|SELECT * FROM ideas WHERE question_id = #{self.question_id} AND parent_id IS null ORDER BY id ASC|
    else
      %Q|SELECT * FROM ideas WHERE parent_id = #{self.parent_id} and role = 1 ORDER BY id ASC| 
    end  
    },
    counter_sql: proc { 
      if self.role == 2
        %Q|SELECT COUNT( * ) FROM ideas WHERE parent_id = #{self.parent_id} and role = 2| 
      elsif self.role == 3
        %Q|SELECT COUNT( * ) FROM ideas WHERE parent_id = #{self.parent_id} and role = 3| 
      elsif self.parent_id.nil?
        %Q|SELECT COUNT( * ) FROM ideas WHERE question_id = #{self.question_id} AND parent_id IS null|
      else
        %Q|SELECT COUNT( * ) FROM ideas WHERE parent_id = #{self.parent_id} and role = 1| 
      end  
      }
      
  has_many :unrated_ideas, class_name: 'Idea', 
    finder_sql: proc { 
      %Q|SELECT ideas.* FROM "ideas" 
      LEFT OUTER JOIN idea_ratings ON ideas.id = idea_ratings.idea_id AND idea_ratings.member_id = #{self.member.id} 
      WHERE ideas.question_id = #{self.id} AND ideas.role = 1 AND idea_ratings.id IS null
      ORDER BY id ASC|
    },
    counter_sql: proc { 
      %Q|SELECT COUNT(ideas.*) FROM "ideas" 
      LEFT OUTER JOIN idea_ratings ON ideas.id = idea_ratings.idea_id AND idea_ratings.member_id = #{self.member.id} 
      WHERE ideas.question_id = #{self.id} AND ideas.role = 1 AND idea_ratings.id IS null|
    }
  
  has_many :attachments, :class_name => 'Upload', :foreign_key => 'par_id', :conditions => 'par_type = 22', :order => 'order_id asc'
    
  attr_accessor :member
  attr_accessor :unrated_ideas_count
  
  before_validation :check_initiative_restrictions, :on=>:create
  before_destroy :check_destroyable

  validate :check_length
  after_save :log_team_content
  
  def check_length
    #logger.debug "Answer check_length self.question_id: #{self.question_id}, self.par_id: #{self.par_id}"
    #q_id = (self.question_id && self.question_id > 0) ? self.question_id : Item.find(self.par_id).o_id
    #range = Question.find(q_id).answer_criteria
    #range = range.match(/(\d+)..(\d+)/)
    range = [0,10,200]
    length = text.scan(/\S/).size
    errors.add(:text, "must be at least #{range[1]} characters") unless length >= range[1].to_i
    errors.add(:text, "must be no longer than #{range[2]} characters") unless self.role !=1 || length <= range[2].to_i 
  end

  def check_destroyable
    if self.version > 0 
      errors.add(:base, "Sorry, you cannot delete a theme that has been edited, but you can hide it.") 
      return false
    end
    if self.ideas.count > 0 
      errors.add(:base, "Sorry, you cannot delete a theme that contains ideas.") 
      return false
    end
    
  end
  
  def check_initiative_restrictions
    allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:parent_id=>self.question_id, :parent_type => 20}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to add an idea.") 
      return false
    end
    true
  end
  
  def self.reorder_siblings( idea_id, ordered_ids, member )
    #allowed,message,team_id = InitiativeRestriction.allow_actionX({:idea_id => idea_id}, 'theming', member)
    allowed = true
    message = 'ok'
    if allowed
      ctr = 0
      if !ordered_ids.nil?
        order_string = ordered_ids.map{|o| "(#{ctr+=1},#{o})" }.join(',')
    
        sql = %Q|UPDATE ideas SET parent_id = #{idea_id}, order_id = new_order_id FROM ( SELECT * FROM (VALUES #{order_string}) vals (new_order_id,idea_id)	) t WHERE id = t.idea_id|
        logger.debug "Use sql: #{sql}"
        ActiveRecord::Base.connection.update_sql(sql)
      end
    end
    return allowed, message
  end
  
  def add_attachments( attachment_ids )
    ctr = 0;
    Upload.where( id: attachment_ids.scan(/\d+/), member_id: self.member_id).order('id ASC').each do |attachment|
      attachment.update_attributes({team_id: self.team_id, question_id: self.question_id, par_type: 22, par_id: self.id, order_id: ctr += 1})
    end
  end
  
  def votes
    IdeaRating.votes(self.id)
  end
  
  def log_team_content
    # log this item into the team_content_logs
    TeamContentLog.new(:team_id=>self.team_id, :member_id=>self.member_id, :o_type=>self.o_type, :o_id=>self.id, :processed=>false).save
  end  
  
  
  def o_type
    20 #type for Idea
  end
  def type_text
    'idea' #type for Idea
  end
  
end
