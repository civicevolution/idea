class ChatActiveSession < ActiveRecord::Base
  
  public
    def self.getSession(cm)
      # I need an active session
      
      # 1. Is there an active chat session for this target
      
      # 2. Does this user have privilege to add chat?
      
      # check if I have a valid session and I have access for it
      
  
      def self.get_current_session(cm)
        session = self.find_by_item_id(cm[:item_id])          
        return nil if session.nil?
        return nil if session.status != 'active'
      
        # I have an active session that applies to this target
      
        # do I have access privilege
        @team = cm[:member].teams.find_by_id( session.team_id )
        # if no privilege, raise an error
        raise TeamAccessDeniedError, "In ChatActiveSession.getSession for item_id: #{cm[:item_id]}" if @team.nil?
      
        # okay, I have a valid session, for this object, and this member has access
        
        # Do I need to check if this session has recent activity, or is there an external mechanism that will kill off old sessions?
        # avoid a race condition where the session is killed just as it is being used again
      
        return session
      end
      
      session = get_current_session(cm) # using the supplied target info
      return session if !session.nil? # return if that provided a valid session
      

      # There is no active chat session for this target
      # create a new chat_session and store in chat_sessions and active_chat_sessions
      
      # get the item/team for this target
      
      item = Item.find_by_id(cm[:item_id])

      # do I have access privilege
      team = cm[:member].teams.find_by_id( item.team_id )
      # if no privilege, raise an error
      raise TeamAccessDeniedError, "In ChatActiveSession.getSession for item.id: #{cm[:item_id]}" if team.nil?

      # member has access to this team and can post
      # create and store a new session
      cs = ChatSession.new({:status=>'active', :par_id=>item.id, :team_id=>item.team_id})
      cs.save
      
      # create a list and save it, store a reference with chat_active_session, return list_id via APE
      list = List.new({:status=>'active', :title=>'Chat summary', :text=>'Summary of this chat session',:member_id=>cm[:member].id, :par_id=>cs.item_id})
      
      list.save
      
      session = self.new({:chat_session_id=>cs.id, :item_id=>cm[:item_id], :team_id=>item.team_id, :status=>'active', :list_id=>list.id })
      session.save
      
      return session
      
      #logger.debug "member_id: #{self.member_id}, tgt_type: #{self.tgt_type}, tgt_id: #{self.tgt_id}, chat_session_id: #{self.chat_session_id}, text: #{self.text}"
      
      
    end
end
