class LiveTalkingPoint < ActiveRecord::Base
  attr_accessible :live_session_id, :group_id, :text, :id_letter, :target, :type, :pos_votes, :neg_votes, :status, :tag, :sub_ltp
  
  attr_accessor :sub_ltp
  
end
