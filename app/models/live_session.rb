class LiveSession < ActiveRecord::Base

  before_create :set_order_id
  
  def set_order_id
    self.order_id ||= (LiveSession.where(:live_event_id=>self.live_event_id).maximum("order_id") || 0) + 1
  end
  
end
