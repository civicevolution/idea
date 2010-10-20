require 'digest/sha1'
require 'net/http'
require 'json'
require 'uri'

class Member < ActiveRecord::Base

  has_many :team_registrations
  has_many :teams, :through => :team_registrations
  has_many :chat_messages

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_uniqueness_of :ape_code
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  
  #validate :email_for_cgg_ce
  
  def before_save 
    self.email = self.email.strip.downcase
  end
  
  
#  validates_attachment_size :photo, :less_than => 2.megabytes if :resource_type == 'upload'
  has_attached_file :photo, 
    :default_url => "/images/:class_default/:style/m.jpg",
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => "mp/:ape_code/:style/m.jpg",
    :url => "http://assets.civicevolution.org/mp/:ape_code/:style/m.jpg",
    :bucket => 'assets.civicevolution.org',
    :styles => {
      '16'  =>   ['16x16#', :jpg],
      '28' =>   ['28x28#', :jpg],
      '36' =>  ['36x36#', :jpg],
      :original => ['250x250>', :jpg]
    }  
  
  before_post_process :image?
                                
  attr_protected :photo_file_name, :photo_content_type, :photo_file_size
    
  def image?
    !(photo_content_type =~ /^image.*/).nil?
  end


  validate :password_non_blank

  def self.authenticate(email, password)
    member = self.find_by_email(email.downcase)
    if member
      expected_password = encrypted_password(password, member.salt)
      if member.hashed_pwd != expected_password
        member = nil
      end
    end
    member
  end
  
  def add_ape_code
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    # I can check to make sure this code isn't already in the table    
    string = ''
    begin
      string  =  (1..14).map{ o[rand(o.length)]  }.join
      dupl = Member.find_by_ape_code(string)
    end while not dupl.nil?
    self.ape_code = string  
    self.save
  end
  
  
  def before_create
    if APP_NAME == 'app_2029' || RAILS_ENV != 'production'
      o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
      # I can check to make sure this code isn't already in the table    
      string = ''
      begin
        string  =  (1..14).map{ o[rand(o.length)]  }.join;
        dupl = Member.find_by_ape_code(string)
      end while not dupl.nil?
      self.ape_code = string  
    else
      # FOR PRODUCTION APPS I WANT TO RESERVE AN id and ape_code from the master application: app_2029
      http = Net::HTTP.new('2029.civicevolution.org', 80)
      resp, data = http.get("/welcome/reserve_member_code?email=#{ URI.escape(self.email, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) }", nil )
      data  = JSON.parse data 
      logger.warn "id: #{data[0]['id']}, ape_code: #{data[0]['ape_code']}"
      self.id = data[0]['id']
      self.ape_code = data[0]['ape_code']
    end
  end
  
  def team_titles
    TeamRegistration.find(:all,
      :select => 't.id, t.title, t.launched',  
      :conditions => ['member_id = ?', self.id],
      :joins => 'as tr inner join teams t on tr.team_id = t.id' 
    )
  end
  
  # 'password' is a virtual attribute
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_pwd = Member.encrypted_password(self.password, self.salt)
  end
  
  private
  
    #def email_for_cgg_ce
    #  # for now the email should be cgg.wa.gov.au or civicevolution.org
    #  errors.add(:email, "must be for CGG staff, @cgg.wa.gov.au") unless self.email.match(/cgg.wa.gov.au$/i) || self.email.match(/civicevolution.org$/i)
    #end
    
    def password_non_blank
      errors.add(:password, "Missing password") if hashed_pwd.blank?
    end
      
    def create_new_salt
      self.salt = self.object_id.to_s + rand.to_s
    end

    def self.encrypted_password(password, salt)
      string_to_hash = password + "wibble" + salt
      Digest::SHA1.hexdigest(string_to_hash)
    end


end
