class ClientDetails < ActiveRecord::Base
  attr_accessible :ip, :session_id, :member_id, :team_id, :url, :user_agent, :error_log
end
