class InitiativeMembers < ActiveRecord::Base

  belongs_to :initiative
  belongs_to :member

  validates_presence_of :initiative_id
  validates_presence_of :member_id
  validates_presence_of :member_category, :message => "- You must select one of the member descriptions"
  validates_presence_of :accept_tos, :message => "- You must accept the Terms of Service"

end
