class LiveEvent < ActiveRecord::Base
  
  has_many :live_sessions, :dependent => :destroy, :order=>'order_id ASC'
  has_many :live_nodes, :dependent => :destroy
  
end
