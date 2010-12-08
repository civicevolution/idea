class TeamMemberRole < ActiveRecord::Base

  def after_create
    logger.debug "Created TeamMemberRole: #{self.inspect}"
    logger.debug "Email role information"
  end
  
  def after_destroy
    logger.debug "Destroyed TeamMemberRole: #{self.inspect}"
  end
  
  def self.roles(team_id)
    TeamMemberRole.all(
      :select => 'member_id, role_id',
      :conditions => ['team_id = ?', team_id]
    )
  end
  
  def self.role_holders(role_id, team_id)
    TeamMemberRole.all(
      :select => 'first_name, last_name, m.id, role_id',
      :joins => 'AS tmr INNER JOIN members AS m ON tmr.member_id = m.id',
      :order => 'first_name, last_name',
      :conditions => ['role_id = ? AND team_id = ?', role_id, team_id]
    )
    
  end


end
