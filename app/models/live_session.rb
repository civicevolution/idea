class LiveSession < ActiveRecord::Base

  has_many :inputs, :class_name => 'LiveSessionData', :conditions => 'io_type = 1'
	has_many :outputs, :class_name => 'LiveSessionData', :conditions => 'io_type = 0'
  
  before_create :set_order_id
  
  attr_accessible :live_event_id, :name, :description, :order_id, :session_type, :published, :starting_time, :duration, :source_session_id, :group_id
  
  def set_order_id
    self.order_id ||= (LiveSession.where(:live_event_id=>self.live_event_id).maximum("order_id") || 0) + 1
  end
  
  
  def micro_themer_data(themer_id)
    
    source_session_id = self.id
    source_input_tags = ['default']
    if self.inputs.size == 0
      live_talking_points = LiveTalkingPoint.where(:live_session_id => self.id, 
        :group_id => LiveNode.where(:role => 'scribe', :parent_id => themer_id).map{|n| n.name.match(/\d+/)[0].to_i} ).order('id ASC')
    else
      live_talking_points = []
      source_input_tags = []
      self.inputs.each do |inp|
        live_talking_points += LiveTalkingPoint.where(:live_session_id => inp.source_session_id, :tag => inp.tag,
          :group_id => LiveNode.where(:role => 'scribe', :parent_id => themer_id).map{|n| n.name.match(/\d+/)[0].to_i} ).order('id ASC')
        source_session_id = inp.source_session_id
        source_input_tags.push( inp.tag )
      end

    end

    live_theming_session = LiveThemingSession.where(:live_session_id => self.id, :themer_id => themer_id)
    live_themes_unordered = LiveTheme.where(:live_session_id => self.id, :themer_id => themer_id)
    
    
    if self.outputs.size == 0
      output_tag = 'default'
    else
      primary_output_field = self.outputs.detect{|o| o.primary_field } || self.outputs[0]
      output_tag = primary_output_field.tag 
    end

    # i need to put the live_themes in the order according to @live_theming_session.theme_group_ids
    live_themes = []
    if !live_theming_session[0].nil?
      if !live_theming_session[0].theme_group_ids.nil?
        live_theming_session[0].theme_group_ids.split(',').each do |id|
          live_themes.push live_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
        end
      end
    end
    live_themes.compact!

    themed_tp_ids = []
    live_themes.each do |theme|
		  if theme.id.to_i > 0
  			tp_ids = theme.live_talking_point_ids
  			tp_ids = tp_ids.nil? ? [] : tp_ids.split(/[^\d]+/).map{|i| i.to_i}
  			theme.example_ids = theme.example_ids.nil? ? [] : theme.example_ids.scan(/\d+/).map{|i| i.to_i}
  			themed_tp_ids += tp_ids
  			theme.talking_points = tp_ids.map{ |id| live_talking_points.detect{ |ltp| ltp.id == id.to_i} }.compact
  		end
		end

    if !live_theming_session.empty?
  		dont_fit_tp_ids = live_theming_session[0].unthemed_ids.nil? ? 
  		  [] : 
  		  live_theming_session[0].unthemed_ids.split(/[^\d]+/).map{|i| i.to_i}
  		  
  		themed_tp_ids += dont_fit_tp_ids
      dont_fit_tp = live_talking_points.select{ |tp| dont_fit_tp_ids.include?(tp.id) }
    else
      dont_fit_tp = []
    end

    live_talking_points = live_talking_points.reject{ |tp| themed_tp_ids.include?(tp.id) }
    
    return source_session_id, live_themes, live_talking_points, dont_fit_tp, source_input_tags, output_tag
  end
  
  
  
  
end
