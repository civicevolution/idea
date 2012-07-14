class LiveSessionData < ActiveRecord::Base
  
  belongs_to :live_session
  attr_accessible :live_session_id, :primary_field, :io_type, :source_session_id, :label, :tag, :qty, :chars, :height
  
end
