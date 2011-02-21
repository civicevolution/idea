class Comment < ActiveRecord::Base

  has_one :resource, :dependent => :destroy
  
  #validates_length_of :text, :in => 5..1500, :allow_blank => false
  
  before_validation_on_create :check_team_access  # checks team access and sets the team_id
  validate_on_update :check_com_edit_access
  
  validate :check_length
      
  after_create :create_item_record
  after_destroy :delete_item_record
  before_destroy :check_item_delete_access
  
  attr_accessor :par_id
  attr_accessor :target_id
  attr_accessor :target_type  
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id
  attr_accessor :par_member_id
  attr_accessor :member
  
  def after_save
    # log this item into the team_content_logs
    TeamContentLog.new(:team_id=>self.team_id, :member_id=>self.member_id, :o_type=>self.o_type, :o_id=>self.id, :par_member_id=>self.par_member_id, :processed=>false).save
  end  

  def check_length
    range = Team.find(self.team_id).com_criteria
    range = range.match(/(\d+)..(\d+)/)
    errors.add(:text, "must be at least #{range[1]} characters") unless text && text.length >= range[1].to_i
    errors.add(:text, "must be no longer than #{range[2]} characters") unless text && text.length <= range[2].to_i
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
