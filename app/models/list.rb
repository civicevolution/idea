class List < ActiveRecord::Base
  
  has_one :item
  has_many :list_item, :dependent => :destroy
  
  validate :check_team_access, :on => :create
  validate :check_item_edit_access, :on => :update
    
  after_create :create_item_record
  after_destroy :delete_item_record
  before_destroy :check_item_delete_access
  
  attr_accessible :format, :anonymous, :status, :title, :text, :member_id
  
  attr_accessor :par_id
  attr_accessor :team_id
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id
  
  def o_type
    7 
  end
  def type_text
    'list' 
  end
  
  def self.active_lists(team_id,id)
    
    if id != 'all'
      active_chats = ChatActiveSession.find(:all, 
        :select => '*', 
        :conditions => ['chat_session_id = ?', id]    
      )
      active_lists = List.find(:all, 
        :select => '*', 
        :conditions => ['cas.id = ?', id],
        :joins => 'as l inner join chat_active_sessions cas on cas.list_id = l.id' 
      )
      list_items = ListItem.find(:all, 
        :select => 'li.*', 
        :conditions => ['cas.id = ?', id],
        :joins => 'as li inner join chat_active_sessions cas on cas.list_id = li.list_id' 
      )      
      
    else
      # get current active chats for this team
      active_chats = ChatActiveSession.find(:all, 
        :select => '*', 
        :conditions => ['team_id = ?', team_id]    
      )
      active_lists = List.find(:all, 
        :select => '*', 
        :conditions => ['cas.team_id = ?', team_id],
        :joins => 'as l inner join chat_active_sessions cas on cas.list_id = l.id' 
      )
      list_items = ListItem.find(:all, 
        :select => 'li.*', 
        :conditions => ['cas.team_id = ?', team_id],
        :joins => 'as li inner join chat_active_sessions cas on cas.list_id = li.list_id',
        :order => 'list_id, "order"'
      )
    end    
    return active_chats,active_lists,list_items
  end
  
  def list_items
    ListItem.find(:all, 
      :select => '*', 
      :conditions => ['list_id = ?', self.id],
      :order => '"order"' 
    )
  end
  
  def reorder_list_items(params)
    #logger.debug "reorder_list_items:\nparams: #{params.inspect}"
    params.keys .each do |key|
      #logger.debug "key: #{key} => #{params[key]}"
      li = /^list_item_(\d+)$/.match(key)
      if !li.nil?
        li = li[1]
        new_ord = params[key]
        #logger.debug "new_ord: #{new_ord}"
        if new_ord != ''
          #logger.debug "Set list_item to order #{new_ord} where id = #{li}"
          ListItem.update_all( '"order" = ' + new_ord, ["id = ? AND list_id = ?", li, self.id])
        end
      end
    end
    # return the id array for the new order
    #SELECT id FROM list_items WHERE list_id = 1 ORDER BY "order"
    items = ListItem.find(:all, 
      :select => 'id', 
      :conditions => ['list_id = ?', self.id],
      :order => '"order"' 
    )
    items.map{|i| i.id }
  end
  
  
end
