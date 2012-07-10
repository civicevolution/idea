class HelpRequest < ActiveRecord::Base
  attr_accessible :category, :name, :email, :message
end
