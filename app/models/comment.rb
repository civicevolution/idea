class Comment < ActiveRecord::Base

  has_one :resource, :dependent => :destroy

  has_one :author, :class_name => 'Member', :foreign_key => 'id',  :primary_key => 'member_id', :select => 'id, first_name, last_name, ape_code, photo_file_name'

  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 3', :order => 'id asc'
   
  belongs_to :talking_point, :foreign_key => 'parent_id'
  #belongs_to :question, :foreign_key => 'parent_id', :conditions => "parent_type = 1"
  belongs_to :comment, :foreign_key => 'parent_id'
  
  # I'm not sure if I want to use this association. It works, but it is less efficient
  # I will eager load members for each set of comments instead of all comments
  #belongs_to :member
  
  
  #validates_length_of :text, :in => 5..1500, :allow_blank => false
  
  #before_validation :check_team_access, :on=>:create  # checks team access and sets the team_id
  
  before_validation :check_initiative_restrictions, :on=>:create
  
  validate :check_com_edit_access, :on=>:update
  
  # temporary validation to prevent posting
  #validates_length_of :text, :in => 500..1500, :allow_blank => false
  validate :check_length
      
  #after_create :create_item_record
  #after_destroy :delete_item_record
  before_destroy :check_item_delete_access
  after_create :log_team_content
  
  attr_accessor :par_id
  attr_accessor :target_id
  attr_accessor :target_type  
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id
  attr_accessor :par_member_id
  attr_accessor :member
  
  attr_accessor_with_default :coms, 0
  attr_accessor_with_default :new_coms, 0
  
  
  def question
    case self.parent_type
      when 1
        Question.find(self.parent_id)
      when 3
        Comment.find(self.parent_id).question
      when 13
        TalkingPoint.find(self.parent_id).question
      end
  end
  
  def log_team_content
    # log this item into the team_content_logs
    TeamContentLog.new(:team_id=>self.team_id, :member_id=>self.member_id, :o_type=>self.o_type, :o_id=>self.id, :par_member_id=>self.par_member_id, :processed=>false).save
  end  

  def check_length
    range = Team.find(self.team_id).com_criteria
    range = range.match(/(\d+)..(\d+)/)
    errors.add(:text, "must be at least #{range[1]} characters") unless text && text.length >= range[1].to_i
    errors.add(:text, "must be no longer than #{range[2]} characters") unless text && text.length <= range[2].to_i
  end
  
  def check_initiative_restrictions
    self.publish = true unless !self.member.confirmed
    #logger.debug "Comment.check_initiative_restrictions"
    self.member_id ||= self.member.id
    allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:parent_id=>self.parent_id, :parent_type => self.parent_type}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add_to_base("Sorry, you do not have permission to add a comment.") 
      return false
    end
    true
  end
  
  def self.com_counts(comment_ids, last_visit_ts)
    return [] if comment_ids.size == 0
    ActiveRecord::Base.connection.select_all(
    %Q|select comment_id,
    (select count(id) from comments where parent_type=3 and parent_id = comment_id) AS coms,
    (SELECT count(id) from comments where parent_type=3 and parent_id = comment_id AND created_at > '#{last_visit_ts}') AS new_coms
    FROM ( VALUES #{ comment_ids.map{ |id| "(#{id})" }.join(',') } ) AS t (comment_id)|
    )
  end
  
  def self.set_question_id_child_comments(comments)
  	child_coms = comments.select{ |c| c.parent_type == 3 }
  	return [] if child_coms.size == 0
  	needed_ids = child_coms.map(&:parent_id).uniq #- comments.map(&:id)
  	#return [] if needed_ids.size == 0
    com_pars = ActiveRecord::Base.connection.select_all(
      %Q|SELECT id, parent_id FROM comments where id in ( #{ needed_ids.join(',') } )|
    )
    com_lookup = []
    com_pars.each{|c| com_lookup[ c['id'].to_i ] = c['parent_id'].to_i}
    child_coms.each{|c| c['question_id'] = com_lookup[c.parent_id]}
  end
    
  def check_team_access
    self.publish = true unless !self.member.confirmed
    logger.debug "validate check_team_access, @par_id: #{@par_id}"
    par_item = Item.find_by_id(@par_id);
    self.team_id = par_item.team_id
    
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add_to_base("Sorry, you do not have permission to add a comment.") 
        return false
      end
      return
    end
    
    is_team_member = !( TeamRegistration.find_by_member_id_and_team_id(self.member_id, self.team_id).nil? )
    # return as ok if user is a team member or parent is the public discussion
    return if is_team_member || par_item.o_type == 11

    logger.debug "check for pub anc self.team_id: #{self.team_id}"
    # determine if this is under a public discussion, is any ancestor, type 11?
    pub_par_item = Item.find(
      :all,
      :select=>'id',
      :conditions=> {:team_id=>self.team_id , :o_type=>11, :id => par_item.ancestors.split(/[^\d]/).map { |s| s.to_i }.uniq }
    )
    #logger.debug "pub_par_item.size: #{pub_par_item.size}"

    if pub_par_item.size == 0
      errors.add_to_base("This discussion is private and you must be a team member to participate.") 
      return false
    end
    # errors.add_to_base("You must sign in to continue")
  end  
  
  def check_com_edit_access
    logger.debug "validate check_com_edit_access"
  
    # I will need to check if the iteam can still be edited
    
    
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add_to_base("Sorry, you do not have permission to edit a comment.") 
        return false
      end
      if self.member_id != self.member.id
        errors.add_to_base("Sorry, only the author can edit this comment.") 
        return false
      end
      return
    end
    
    
    # are you a still a team member
    is_team_member = !( TeamRegistration.find_by_member_id_and_team_id(self.member_id, self.team_id).nil? )
    # return as ok if user is a team member
    return if is_team_member

    # determine if this is under a public discussion, is any ancestor, type 11?
    item = Item.find_by_o_id_and_o_type(self.id, self.o_type)
    pub_par_item = Item.find(
      :all,
      :select=>'id',
      :conditions=> {:team_id=>self.team_id , :o_type=>11, :id => item.ancestors.split(/[^\d]/).map { |s| s.to_i }.uniq }
    )
    #logger.debug "pub_par_item.size: #{pub_par_item.size}"
    if pub_par_item.size == 0
      errors.add_to_base("This discussion is private and you must be a team member to participate.") 
      return false
    end
  end  
  
  def self.member_confirmed_publish(member_id)
    ActiveRecord::Base.connection.update_sql("UPDATE comments SET publish = true where member_id = #{member_id} AND status != 'prereview'");    
  end
  

  def o_type
    3 #type for Comments
  end
  def type_text
    'comment' #type for Comments
  end

end
