class ClientLoadTime < ActiveRecord::Base
  attr_accessible :ip, :session_id, :team_id, :member_id, :page_load, :ape_load, :all_init, :user_agent, :height, :width
end
