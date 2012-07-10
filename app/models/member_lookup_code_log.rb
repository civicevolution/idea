class MemberLookupCodeLog < ActiveRecord::Base
  
  attr_accessible :member_id, :code, :scenario, :target_id
  
  def self.get_all(start_time = Time.local(2000,"jan",1), end_time = Time.now)
    
    MemberLookupCodeLog.all(
      :select => 'mlcl.*, first_name, last_name, email',
      :conditions => ['mlcl.created_at > ? AND mlcl.updated_at < ? AND member_id > 10', start_time, end_time],
      :joins => 'as mlcl inner join members as m on mlcl.member_id = m.id'
    )
      
  end
  
end
