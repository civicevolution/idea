class LiveThemingSessions::MacroThemerPresenter   
  
  def initialize(live_node, session_id, themer_id)     
    @live_node = live_node
    @session = LiveSession.find_by_id(session_id)
    @themer_id = themer_id || @live_node.id
    
    
    @source_session_id, @live_themes, @my_themes, @dont_fit_tp, source_input_tags, output_tag =
      @session.macro_themer_data(@live_node, @themer_id)

    @channels = ["_event_#{@live_node.live_event_id}", "_session_#{source_session_id}_macrothemer" ]

    @macro_session = LiveSession.find_by_sql(%Q|select * from live_sessions where id in (select live_session_id from live_session_data where io_type = 1 and source_session_id = #{@session.id})|)
    @macro_session = @macro_session.size > 0 ? @macro_session[0] : @session
    
    @page_data = {type: 'macro theming', session_id: @session.id, source_session_id: source_session_id, 
      session_title: @session.name, output_tag: output_tag, source_input_tags: source_input_tags}  
    
  end    

  def source_session_id
    @source_session_id
  end
  
  def unthemed_ideas
    @live_themes
  end
  
  def dont_fit_tp
    @dont_fit_tp
  end

  def parked_ideas
    @dont_fit_tp
  end
  
  def live_themes
    @live_themes
    @my_themes
  end
  
  def my_themes
    @my_themes
  end
  
  def macro_session
    @macro_session    
  end
  
  def channels
    @channels
  end
  
  def disable_editing
    (@macro_session.published || @live_node.role != 'theme') ? true : false
  end

  def page_data
    @page_data
  end
  
  def page_title
    @page_title = "Macro theming for: #{@session.name}"
  end
  
  def themers
    @themers ||= begin
      LiveNode.where(role: 'theme', parent_id: @live_node.id ).order('name ASC')
    end
  end
    
  def page_data
    @page_data
  end
  
end