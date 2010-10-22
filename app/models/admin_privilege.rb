class AdminPrivilege < ActiveRecord::Base
  
  def self.read_privileges( member_id, initiative_id )
    privs = AdminPrivilege.find_by_sql([ %q| select ap.title 
      from admin_privileges ap, admin_groups ag, admins a 
      where a.member_id = ? and a.initiative_id = ? and ag.id = a.admin_group_id and ap.admin_group_id = ag.id|, member_id, initiative_id ]
      )
      privs.map{ |p| p.title}.uniq
  end
  
end
