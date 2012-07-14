class InitiativeMembers < ActiveRecord::Base

  attr_accessible :initiative_id, :member_id, :accept_tos, :member_category, :email_opt_in
  
  belongs_to :initiative
  belongs_to :member

  validates_presence_of :initiative_id
  validates_presence_of :member_id
  validates_presence_of :member_category, :message => "- You must select one of the member descriptions"
  validates_presence_of :accept_tos, :message => "- You must accept the Terms of Service"

  def o_type
    20 #type for Endorsement
  end
  def type_text
    'initiative_member' #type for Answers
  end

end
