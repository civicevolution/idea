class LiveThemingSession < ActiveRecord::Base
  attr_accessible :live_session_id, :themer_id, :text, :order_id, :live_talking_point_ids, :example_ids, :visible, :tag
  
end
