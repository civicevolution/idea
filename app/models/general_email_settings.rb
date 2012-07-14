class GeneralEmailSettings < ActiveRecord::Base
  attr_accessible :member_id, :accept_broadcast_messages, :forward_messages
  
end
