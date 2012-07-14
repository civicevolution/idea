class Initiative < ActiveRecord::Base
  
  has_many :initiative_members, :class_name => 'InitiativeMembers' 
  has_many :members, :through => :initiative_members
  
  attr_accessible :title, :description, :min_members, :max_members, :max_teams_per_member, :limit_access, :access_code, :can_propose_team, :prescreen_proposals, :timezone, :lang, :config_id, :public_face, :public_face_rating_threshold, :join_test, :approve_join, :send_invites, :approve_invites, :admin_groups, :country, :state, :county, :city, :domain
  
  
end
