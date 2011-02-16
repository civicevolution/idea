class Answer < ActiveRecord::Base

  has_many :item_diffs, :foreign_key => 'o_id',  :dependent => :destroy
  has_one :item
  
  validate :check_length
  validate_on_create :check_team_access
  
  validate_on_update :check_item_edit_access
  
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
  
  @record_saved = false
  
  def after_save
    if !@record_saved
      # log this item into the team_content_logs
      TeamContentLog.new(:team_id=>self.team_id, :member_id=>self.member_id, :o_type=>self.o_type, :o_id=>self.id, :par_member_id=>self.par_member_id, :processed=>false).save 
      @record_saved = true
    end
  end  


  def check_length
    #logger.debug "Answer check_length self.question_id: #{self.question_id}, self.par_id: #{self.par_id}"
    q_id = (self.question_id && self.question_id > 0) ? self.question_id : Item.find(self.par_id).o_id
    range = Question.find(q_id).answer_criteria
    range = range.match(/(\d+)..(\d+)/)
    errors.add(:text, "must be at least #{range[1]} characters") unless text && text.length >= range[1].to_i
    errors.add(:text, "must be no longer than #{range[2]} characters") unless text && text.length <= range[2].to_i
  end


# code required to record revision history for this item
  def before_create 
    self.ver = 0
  end
  
  def check_team_access
    logger.debug "validate check_team_access, @par_id: #{@par_id}"

    par_item = Item.find_by_id(@par_id)
    self.team_id = par_item.team_id
    self.question_id = par_item.o_id
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add_to_base("Sorry, you do not have permission to add an answer.") 
        return false
      end
      return
    end
    
    begin
      par_item = Item.find_by_id(@par_id);
      @team = Member.find_by_id(self.member_id).teams.find_by_id( par_item.team_id )
    rescue
    end
    #raise TeamAccessDeniedError, "In check_team_access for par_id: #{@par_id}" if @team.nil?
    if @team.nil?
      errors.add_to_base("You must sign in to continue") 
    else
      self.team_id = @team.id # this will be used to construct the item record
      self.question_id = par_item.o_id
    end
  end  
  
  def check_item_edit_access
    logger.debug "validate check_item_edit_access"
    
    if !self.member.nil?
      # this is access check for the idea page version
      allowed,message = InitiativeRestriction.allow_action({:team_id=>self.team_id}, 'contribute_to_proposal', self.member)
      if !allowed
        errors.add_to_base("Sorry, you do not have permission to edit this answer.") 
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
  
  
  
  after_save :create_history_record
  
  def store_initial_values
    # save the previous state, this must be called manually because I don't want to call it everytime I read an answer record
    # call store_initial_values after instantiating the object, but before I add the new parameters
    self.previousText = self.text || ''
    self.previousVer = self.ver || 0
    self.previousUpdated_at = self.updated_at || nil
    self.par_member_id = self.member_id
  end

  attr_accessor :previousText
  attr_accessor :previousVer
  attr_accessor :previousUpdated_at
  attr_accessor :remaining_answers
  
  @created_history_record = false
  
  def create_history_record
    return if @created_history_record # only create record once per save. update ver attribute will revisit here
    diff = ItemDiff.new(:item => self)
    diff.save!
    @created_history_record = true
    self.update_attribute :ver, diff.ver  # update the item ver
    
    # set a flag if more answers are allowed for this question
    num_allowed_ans = Question.find(:first, :select => "num_answers", :conditions => ['id = ?', self.question_id ]);
    num_allowed_ans = num_allowed_ans.nil? ? 0 : num_allowed_ans.num_answers;
    num_ans = Answer.count(:id, :conditions => ['question_id = ?', self.question_id ])
    self.remaining_answers = num_allowed_ans - num_ans
  end
# end of code for revision history  

  
  def o_type
    2 #type for Answers
  end
  def type_text
    'answer' #type for Answers
  end

  
end
