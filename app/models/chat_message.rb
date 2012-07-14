class ChatMessage < ActiveRecord::Base
  belongs_to :chat_session
  belongs_to :member

  validates_presence_of :text

  attr_accessible :chat_session_id, :member_id, :text
  
  attr_accessor :item_id
  attr_accessor :team_id

  def self.get_transcript(session_id)
    #@chat_messages = ChatMessage.find_all_by_chat_session_id(chat_session_id, :order=> 'id')
    self.find(:all,
      :select => 'first_name, pic_id, text, cm.created_at',  
      :conditions => ['chat_session_id = ?', session_id],
      :joins => 'as cm inner join members m on cm.member_id = m.id' 
    )
    
#    ChatMessage.find(:all,
#      :select => '*', 
#      :conditions => ['chat_session_id = ?', session_id],
#      :joins => 'as cm inner join members m on cm.member_id = m.id' 
#    )
#    ChatMessage.find_by_sql('select first_name, pic_id, text from chat_messages as cm inner join members m on cm.member_id = m.id where chat_session_id = 18')
#    # c[0].pic_id  c[0].first_name
#    'select * from chat_messages as cm inner join members m on cm.member_id = m.id where chat_session_id = 18
  end
  
  def o_type
    6 
  end

  def type_text
    'chat_message' 
  end
   
end
