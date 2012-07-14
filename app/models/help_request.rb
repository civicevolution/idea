class HelpRequest < ActiveRecord::Base
  attr_accessible :client_details_id, :name, :email, :category, :message
  
end
