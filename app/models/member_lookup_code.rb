require 'uuidtools'
class MemberLookupCode < ActiveRecord::Base
  
  validates_uniqueness_of :code
  
  def self.get_code(member_id, data)
    begin
      string = UUIDTools::UUID.timestamp_create().to_s
      dupl = MemberLookupCode.find_by_code(string)
    end while not dupl.nil?
    mlc = MemberLookupCode.new(:member_id=>member_id, :code=>string, :scenario=>data[:scenario])
    mlc.save
    mlcl = MemberLookupCodeLog.new(:member_id=>member_id, :code=>string, :scenario=>data[:scenario], :target_id=>data[:target_id])
    mlcl.save
    mlc.code
  end
  
  
  def self.get_member(code, data)
    mlc = MemberLookupCode.find_by_code( code )
    if mlc
      mlc.destroy
      mlcl = MemberLookupCodeLog.find_by_code( code )
      mlcl.target_url = data[:target_url]
      mlcl.save
      
      return Member.find_by_id(mlc.member_id)
    else
      return nil
    end
  end
  
end
