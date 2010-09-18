class InitiativeMembers < ActiveRecord::Base


  validates_presence_of :initiative_id
  validates_presence_of :member_id
  validates_presence_of :member_category, :message => "must select one"
  validates_presence_of :accept_tos, :message => "must accept the Terms of Service"
  
  


end
