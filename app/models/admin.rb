class Admin < ActiveRecord::Base
  
  #attr_accessible :member_id, :admin_group_id, :initiative_id
  
  def self.list_admins
    Admin.find_by_sql([ %q| SELECT id, first_name, last_name FROM members WHERE id IN (SELECT DISTINCT member_id FROM admins) ORDER BY first_name, last_name;| ] )
    
  end
  
  
  def self.list_admin_groups(member_id)
    Admin.find_by_sql([ %q| SELECT ag.title AS ag_title, ag.id AS ag_id, i.id as i_id, i.title AS i_title 
      FROM admin_groups ag, admins a, initiatives i 
      WHERE ag.id = a.admin_group_id AND i.id = a.initiative_id AND a.member_id = ?;|, member_id])
    
  end
  
end

#SELECT ag.title AS ag_title, ag.id AS ag_id, i.id as i_id, i.title AS i_title FROM admin_groups ag, admins a, initiatives i WHERE ag.id = a.admin_group_id AND i.id = a.initiative_id AND a.member_id = 1;
#
#SELECT ARRAY (SELECT ag.title FROM admin_groups ag, admins a WHERE ag.id = a.admin_group_id AND a.member_id = m.id)) AS admin_groups
#
#SELECT id, first_name, last_name FROM members WHERE id IN (SELECT DISTINCT member_id FROM admins) ORDER BY first_name, last_name;