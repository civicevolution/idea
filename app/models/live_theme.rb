class LiveTheme < ActiveRecord::Base
  attr_accessible :live_session_id, :themer_id, :text, :order_id, :live_talking_point_ids, :example_ids, :visible, :tag, :talking_points, :themes, :examples, :macro, :theme_type, :version, :points, :percentage
  
  attr_accessor :talking_points, :themes, :examples, :macro, :points, :percentage
  
  def constituent_ideas
    @constituent_ideas ||= begin
      ltp_array = self.live_talking_point_ids.try { |ids| ids.scan(/\d+/).map(&:to_i) } || []
      ltp = LiveTalkingPoint.where(id: ltp_array)
      ltp_array.map{|id| ltp.detect{ |tp| tp.id == id}}
    end
  end

  def constituent_micro_themes
    @constituent_micro_themes ||= begin
      lt_array = self.live_talking_point_ids.try { |ids| ids.scan(/\d+/).map(&:to_i) } || []
      lt = LiveTheme.where(id: lt_array)
      lt_array.map{|id| lt.detect{ |lt| lt.id == id} }
    end
  end
    
end
