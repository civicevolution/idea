class Page < ActiveRecord::Base
  
  has_one :item
  
  validate :check_team_access, :on => :create
  validate :check_team_update_access, :on => :update
  
  #validate_on_update :check_item_edit_access
    
  after_create :create_item_record
  after_destroy :delete_item_record
  before_destroy :check_item_delete_access
  
  attr_accessible :page_title, :html, :chat_par_id, :chat_title, :discussion, :classname, :css, :nav_title
  
  attr_accessor :par_id
  attr_accessor :team_id
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id
  attr_accessor :order
  
  attr_accessor :target_id
  attr_accessor :target_type
  
  def check_team_access
    par_item = Item.find_by_id(self.par_id)
    raise TeamAccessDeniedError, "In check_team_access for par_id: #{self.par_id}" if par_item.nil?
    self.team_id = par_item.team_id # this will be used to construct the item record
  end
  
  def check_team_update_access
    item = Item.find_by_o_id_and_o_type(self.id,9)
    raise TeamAccessDeniedError, "In check_team_access for par_id: #{self.par_id}" if item.nil?
    self.team_id = item.team_id # this will be used to construct the item record
  end
  
  def o_type
    9 
  end
  def type_text
    'page' 
  end


end
