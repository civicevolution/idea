class ChatSession < ActiveRecord::Base
  
  has_one :item
  has_many :chat_message, :dependent => :destroy


  #validate_on_create :check_team_access
  #validate_on_update :check_item_edit_access
    
  after_create :create_item_record
  after_destroy :delete_item_record
  before_destroy :check_item_delete_access
  
  attr_accessor :par_id
  attr_accessor :team_id
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id



  def member_id
    0 
  end
  def o_type
    5 
  end
  def type_text
    'chat_session' 
  end
    
end
