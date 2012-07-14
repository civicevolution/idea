class LiveSession < ActiveRecord::Base

  has_many :inputs, :class_name => 'LiveSessionData', :conditions => 'io_type = 1'
	has_many :outputs, :class_name => 'LiveSessionData', :conditions => 'io_type = 0'
  
  before_create :set_order_id
  
  attr_accessible :live_event_id, :name, :description, :order_id, :session_type, :published, :starting_time, :duration, :source_session_id, :group_id
  
  def set_order_id
    self.order_id ||= (LiveSession.where(:live_event_id=>self.live_event_id).maximum("order_id") || 0) + 1
  end
  
end
