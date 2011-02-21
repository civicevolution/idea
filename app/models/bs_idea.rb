class BsIdea < ActiveRecord::Base
  
  has_one :question
  #has_many :bs_idea_rating, :dependent => :destroy

  #validates_length_of :text, :in => 5..1500, :allow_blank => false
  
  validate :check_length
  validate_on_create :check_team_access
  validate_on_update :check_item_edit_access
    
  after_create :create_item_record
  after_destroy :delete_item_record
    
  #before_destroy :check_item_delete_access
  
  attr_accessor :item_id
  attr_accessor :par_id
  attr_accessor :target_id
  attr_accessor :target_type  
  attr_accessor :insert_mode
  attr_accessor :member
    
  def after_save
    # log this item into the team_content_logs
    TeamContentLog.new(:team_id=>self.team_id, :member_id=>self.member_id, :o_type=>self.o_type, :o_id=>self.id, :processed=>false).save
  end  
  

  def after_find
    item = Item.find_by_o_id_and_o_type(self.id, 12) 
    self.item_id = item.id if item
  end

  def o_type
    12
  end
  def type_text
    'brainstorming idea' 
  end  

  def check_length
    range = Question.find(self.question_id).idea_criteria
    range = range.match(/(\d+)..(\d+)/)
    errors.add(:text, "must be at least #{range[1]} characters") unless text && text.length >= range[1].to_i
    errors.add(:text, "must be no longer than #{range[2]} characters") unless text && text.length <= range[2].to_i
  end
    
  def check_team_access
    self.publish = true unless !self.member.confirmed
    #logger.debug "check_team_access, for BsIdea question_id = #{self.question_id}"
    
    self.team_id = ActiveRecord::Base.connection.select_value( "SELECT team_id FROM items where o_id = #{self.question_id} and o_type = 1" )
    
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add_to_base("Sorry, you do not have permission to add a brainstorming idea.") 
        return false
      end
      return
    end
    
    
    begin
      @team = Member.find_by_id(self.member_id).teams.find_by_id( Item.find_by_o_id_and_o_type(self.question_id,1).team_id )
    rescue
    end
    if @team.nil?
      errors.add_to_base("You must sign in to continue") 
    else
      self.team_id = @team.id # this will be used to construct the item record
    end
  end  
  
  def check_item_edit_access
    #logger.debug "validate check_item_edit_access"
    
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add_to_base("Sorry, you do not have permission to edit this brainstorming idea.") 
        return false
      end
      if self.member_id != self.member.id
        errors.add_to_base("Sorry, only the author can edit this brainstorming idea.") 
        return false
      end
      return
    end
    
    
    begin
      @team = Member.find_by_id(self.member_id).teams.find_by_id( self.team_id )
    rescue
    end
    if @team.nil?
      errors.add_to_base("You must sign in to continue") 
    end
  end  
  
  
  def comments_with_ratings(memberId)
    comments = Comment.find_by_sql([ %q|SELECT c.id,   
      SUM(up) AS up,
      SUM(down) AS down,
      (SELECT CASE WHEN up = 1 THEN 1 ELSE -1 END FROM com_ratings WHERE member_id = ? AND comment_id = c.id) AS my_vote,
      c.member_id, c.text, c.anonymous, c.created_at, c.updated_at, status, par_id, sib_id, "order", target_id, target_type, i.id AS item_id
      FROM comments c 
      LEFT JOIN items AS i ON i.o_id = c.id AND i.o_type = 3
      LEFT OUTER JOIN com_ratings cr ON c.id = cr.comment_id
      WHERE i.team_id = ?
      AND o_type = 3 
      AND ? = ANY (ancestors)
      GROUP BY c.id, c.member_id, c.text, c.anonymous, c.created_at, c.updated_at, c.status, par_id, sib_id, "order", target_id, target_type, i.id|,
      memberId, self.team_id, self.item_id ]
    )
    resources = Resource.find_all_by_comment_id( comments.collect {|c| c.id } )
    authors = Member.all(:conditions=> {:id => (comments.collect {|c| c.member_id }.uniq) })
    return comments, resources, authors
    
  end

  def self.member_confirmed_publish(member_id)
    ActiveRecord::Base.connection.update_sql("UPDATE bs_ideas SET publish = true where member_id = #{member_id}");    
  end

    
end
