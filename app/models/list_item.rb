class ListItem < ActiveRecord::Base

  has_many :item_diffs, :foreign_key => 'o_id',  :dependent => :destroy
  belongs_to :list

#  validates_presence_of :text
#  validates_length_of :text, :in => 5..500, :allow_blank => false
#  
#  validate_on_create :check_team_access
#  
#  validate_on_update :check_item_edit_access
#  
#  after_create :create_item_record
#  after_destroy :delete_item_record
  before_destroy :check_item_delete_access

  attr_accessible :list_id, :order, :member_id, :anonymous, :text, :ver, :deleted
  
  attr_accessor :team_id  
  attr_accessor :itemDestroyed

  # code required to record revision history for this item
    def before_create 
      self.ver = 0
      # set the order value, 1 if first rec or 1+ max
      #SELECT max("order") FROM list_items WHERE list_id = self.list_id
      o = ListItem.maximum('"order"', :conditions=>['list_id = ?', self.list_id])
      self.order = o ? o.to_i+1 : 1
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
    8 
  end
  def type_text
    'list_item' 
  end
  
end
