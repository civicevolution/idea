class Invite < ActiveRecord::Base
  attr_accessible :member_id, :initiative_id, :team_id, :first_name, :last_name, :email, :_ilc

end
