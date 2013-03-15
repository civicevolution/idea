class LiveThemingSessions::MicroThemerPresenter   
  
  def initialize(live_node, session_id, themer_id)     
    @live_node = live_node
    @session = LiveSession.find_by_id(session_id)
    @themer_id = themer_id || @live_node.id
    
    
    @source_session_id, @live_themes, @live_talking_points, @dont_fit_tp, source_input_tags, output_tag = @session.micro_themer_data(@themer_id)
      
    @channels = ["_event_#{@live_node.live_event_id}", "_session_#{@source_session_id}_microthemer_#{@themer_id}" ]

    @macro_session = LiveSession.find_by_sql(%Q|select * from live_sessions where id in (select live_session_id from live_session_data where io_type = 1 and source_session_id = #{@session.id})|)
    @macro_session = @macro_session.size > 0 ? @macro_session[0] : @session
    
    @page_data = {type: 'micro theming', session_id: @session.id, source_session_id: @source_session_id, 
      session_title: @session.name, output_tag: output_tag, source_input_tags: source_input_tags};
    
  end    

  def source_session_id
    @source_session_id
  end
  
  def live_talking_points
    @live_talking_points
  end

  def unthemed_ideas
    @live_talking_points
  end
  
  def dont_fit_tp
    @dont_fit_tp
  end

  def parked_ideas
    @dont_fit_tp
  end
  
  def live_themes
    @live_themes
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
    @page_title = "Theme for: #{@session.name}, Tables: #{self.tables.join(',')}"
  end
  
  def tables
    @tables ||= begin
      names = ActiveRecord::Base.connection.select_values(%Q|SELECT name FROM live_nodes WHERE role = 'scribe' AND parent_id = #{@themer_id} ORDER BY name|)
      # get the numbers from the name and order them
      begin
        names.map{|tab| tab.match(/\d+/)[0].to_i}
      rescue
        ['unknown']
      end    
    end
  end
  
  def page_data
    @page_data
  end
  
end