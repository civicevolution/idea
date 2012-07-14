class AdminPrivilege < ActiveRecord::Base
  attr_accessible :admin_group_id, :title
  
  def self.read_privileges( member_id, initiative_id )
    privs = AdminPrivilege.find_by_sql([ %q| select ap.title 
      from admin_privileges ap, admin_groups ag, admins a 
      where a.member_id = ? and a.initiative_id = ? and ag.id = a.admin_group_id and ap.admin_group_id = ag.id|, member_id, initiative_id ]
      )
      privs.map{ |p| p.title}.uniq
  end
  
  
  def self.list_privileges(group_id)
    AdminPrivilege.find_by_sql([ %q| SELECT id, title FROM admin_privileges 
      WHERE admin_group_id  = ?
      ORDER BY title;|, group_id ] )
    
  end
  
  def self.check_admin(member_id,initiative_id, privilege)
    AdminPrivilege.first(:select =>'member_id',
    :joins =>'ap INNER JOIN admins AS a ON a.admin_group_id = ap.admin_group_id',
    :conditions=>['member_id = ? AND title = ? AND initiative_id = ?',member_id, privilege, initiative_id]
    )
  end
end
