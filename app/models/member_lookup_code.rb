class MemberLookupCode < ActiveRecord::Base
  
  validates_uniqueness_of :code
  
  def before_create
    # remove any records for this member id
    logger.debug "delete records for member_id: #{self.member_id}"
    mlc = MemberLookupCode.find_by_member_id(self.member_id)
    if mlc
      mlc.destroy();
    end
    
    # create a unique code
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    # I can check to make sure this code isn't already in the table    
    string = ''
    begin
      string  =  (1..32).map{ o[rand(o.length)]  }.join;
      dupl = MemberLookupCode.find_by_code(string)
    end while not dupl.nil?
    self.code = string  
    
  end
  
  
end
