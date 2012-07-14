require 'uuidtools'
class EmailLookupCode < ActiveRecord::Base
  
  attr_accessible :code, :email

  
  validates_uniqueness_of :code
  
  def self.get_code(email)
    email = email.strip.downcase
    rec = EmailLookupCode.find_by_email(email)
    return rec.code if !rec.nil?
    begin
      string = UUIDTools::UUID.timestamp_create().to_s
      dupl = EmailLookupCode.find_by_code(string)
    end while not dupl.nil?
    elc = EmailLookupCode.new(:email=>email, :code=>string)
    elc.save
    elc.code
  end

  def self.get_email(code)
    elc = EmailLookupCode.find_by_code( code )
    if elc
      #elc.destroy
      return elc.email
    else
      return nil
    end
  end
  
end
