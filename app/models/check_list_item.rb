class CheckListItem < ActiveRecord::Base
  
  attr_accessible :team_id, :title, :description, :par_id, :order, :completed, :request_details, :details, :discussion
  
end
