class ClientDetails < ActiveRecord::Base
  attr_accessible :session_id, :ip, :member_id, :team_id, :url, :user_agent, :error_log, :load_time
end
