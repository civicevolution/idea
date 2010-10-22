class PageChatMessage < ActiveRecord::Base
  
  belongs_to :member

  validate :check_team_access
  validates_presence_of :text
  #validates_length_of :text, :in => 2..1000, :allow_blank => false
  validates_length_of :text, :maximum=>1000, :message=>"must be less than {{count}} characters"
  #validates_length_of :text, :minimum=>2, :message=>"must be more than {{count}} characters"

  attr_accessor :team_id

  def self.get_transcript(mem_id,page_id)
    #logger.debug "get_transcription mem_id: #{mem_id}, page_id: #{page_id}"
    begin
      team_id = Item.find_by_o_id_and_o_type(page_id, 9).team_id
      team = Member.find_by_id(mem_id).teams.find_by_id( team_id )
    rescue
    end
    if team.nil?
      #logger.debug "Member does not have access to this team, do not share the transcript"
      '<html><body><p>Sorry, you do not have access to this chat transcript</p></body></html>'
    else
      chats = PageChatMessage.all(
        :select => 'member_id, text, created_at',
        :conditions => ['page_id = ?', page_id] 
      )
      author_ids = chats.collect {|c| c.member_id }.uniq
      authors = Member.all(:conditions=> {:id => author_ids })
      return chats, authors
      
      #PageChatMessage.find(:all,
      #  :select => 'first_name, pic_id, text, cm.created_at',  
      #  :conditions => ['page_id = ?', page_id],
      #  :joins => 'as cm inner join members m on cm.member_id = m.id' 
      #)
    end
  end
  
  def check_team_access
    #logger.debug "validate check_team_access"
    begin
      self.team_id = Item.find_by_o_id_and_o_type(self.page_id, 9).team_id
      @team = Member.find_by_id(self.member_id).teams.find_by_id( self.team_id )
    rescue
    end
    #raise TeamAccessDeniedError, "In check_team_access for par_id: #{@par_id}" if @team.nil?
    if @team.nil?
      logger.debug "add page chate error sign in"
      errors.add_to_base("You must sign in to continue") 
    end
  end  


  def o_type
    6 
  end

  def type_text
    'chat_message' 
  end

end
