class MemberLookupCode < ActiveRecord::Base
  
  validates_uniqueness_of :member_id
  validates_uniqueness_of :code
  
  def self.get_code(member_id)
    mlc = MemberLookupCode.find_by_member_id(member_id)
    if mlc.nil?
      # create a unique code
      o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
      # I can check to make sure this code isn't already in the table    
      string = ''
      begin
        string  =  (1..32).map{ o[rand(o.length)]  }.join;
        dupl = MemberLookupCode.find_by_code(string)
      end while not dupl.nil?
      mlc = MemberLookupCode.new(:member_id=>member_id, :code=>string)
      mlc.save
    end
    mlc.code
  end
  
  
  def self.get_member(code)
    mlc = MemberLookupCode.find_by_code( code )
    if mlc
      mlc.destroy
      return Member.find_by_id(mlc.member_id)
    else
      return nil
    end
  end
  
end
