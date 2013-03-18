class LiveTheme < ActiveRecord::Base
  attr_accessible :live_session_id, :themer_id, :text, :order_id, :live_talking_point_ids, :example_ids, :visible, :tag, :talking_points
  
  attr_accessor :talking_points
  
  def constituent_ideas
    ltp_array = self.live_talking_point_ids.scan(/\d+/).map(&:to_i)
    ltp = LiveTalkingPoint.where(id: ltp_array)
    talking_points = ltp_array.map{|id| ltp.detect{ |tp| tp.id == id}}
  end
    
end
