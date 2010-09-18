class Question < ActiveRecord::Base
  
  has_many :item_diffs, :foreign_key => 'o_id',  :dependent => :destroy
  has_one :item
  
  validates_presence_of :text
  validates_length_of :text, :in => 5..200, :allow_blank => false
  
  validate_on_create :check_team_access
  validate_on_update :check_item_edit_access
    
  after_create :create_item_record
  after_destroy :delete_item_record
  before_destroy :check_item_delete_access
  
  #before_validation :check_team_access, :create_item_record
  
  #debugger

  attr_accessor :par_id
  attr_accessor :target_id
  attr_accessor :target_type
  attr_accessor :team_id  
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id
  attr_accessor :order
  
  # code required to record revision history for this item
  def before_create 
    self.ver = 0
  end

  after_save :create_history_record

  def store_initial_values
    # save the previous state, this must be called manually because I don't want to call it everytime I read an answer record
    # call store_initial_values after instantiating the object, but before I add the new parameters
    self.previousText = self.text || ''
    self.previousVer = self.ver || 0
    self.previousUpdated_at = self.updated_at || nil
  end

  attr_accessor :previousText
  attr_accessor :previousVer
  attr_accessor :previousUpdated_at

  @created_history_record = false

  def create_history_record
    return if @created_history_record # only create record once per save. update ver attribute will revisit here
    diff = ItemDiff.new(:item => self)
    diff.save!
    @created_history_record = true
    self.update_attribute :ver, diff.ver  # update the item ver
  end
  # end of code for revision history  
  
  
  def o_type
    1 #type for Questions
  end
  def type_text
    'question' #type for Questions
  end
  
  
end
