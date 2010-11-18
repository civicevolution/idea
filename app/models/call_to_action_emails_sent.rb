class CallToActionEmailsSent < ActiveRecord::Base
  
  def self.get_all(start_time = Time.local(2000,"jan",1), end_time = Time.now)
    
    CallToActionEmailsSent.all(
      :select => 'ctae.*, first_name, last_name, email',
      :conditions => ['ctae.created_at > ? AND ctae.updated_at < ? AND member_id > 10', start_time, end_time],
      :joins => 'as ctae inner join members as m on ctae.member_id = m.id'
    )
      
  end
end
