class BsIdea < ActiveRecord::Base
  
  has_one :question
  #has_many :bs_idea_rating, :dependent => :destroy

  #validates_length_of :text, :in => 5..1500, :allow_blank => false
  
  validate :check_length
  validate_on_create :check_team_access
  validate_on_update :check_item_edit_access
    
  #before_destroy :check_item_delete_access
  
  def after_save
    # log this item into the team_content_logs
    TeamContentLog.new(:team_id=>self.team_id, :member_id=>self.member_id, :o_type=>self.o_type, :o_id=>self.id, :processed=>false).save
  end  
  

  def o_type
    11 
  end
  def type_text
    'bs_idea' 
  end  

  def check_length
    range = Question.find(self.question_id).idea_criteria
    range = range.match(/(\d+)..(\d+)/)
    errors.add(:text, "must be at least #{range[1]} characters") unless text && text.length >= range[1].to_i
    errors.add(:text, "must be no longer than #{range[2]} characters") unless text && text.length <= range[2].to_i
  end
    
  def check_team_access
    #logger.debug "check_team_access, for BsIdea question_id = #{self.question_id}"
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
    begin
      @team = Member.find_by_id(self.member_id).teams.find_by_id( self.team_id )
    rescue
    end
    if @team.nil?
      errors.add_to_base("You must sign in to continue") 
    end
  end  
  

    
end
