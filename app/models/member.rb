require 'digest/sha1'
require 'net/http'
require 'json'
require 'uri'

class Member < ActiveRecord::Base

  has_many :team_registrations
  has_many :teams, :through => :team_registrations
  has_many :chat_messages
  has_many :comments
  has_many :initiative_members, :class_name => 'InitiativeMembers'
  #InitiativeMembers
  has_many :initiatives, :class_name => 'Initiative', :through => :initiative_members 

  attr_accessible :email, :first_name, :last_name, :pic_id, :init_id, :hashed_pwd, :confirmed, :city, :state, :country, :location, :access_code, :salt, :ape_code, :photo_file_name, :photo_content_type, :photo_file_size, :ip, :email_ok
  
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_uniqueness_of :ape_code
  attr_accessor :password_confirmation
  validates_confirmation_of :password
  attr_accessor :domain
  
  attr_accessor :question_last_visit_ts
  
  attr_accessor :stats
  after_initialize do |member|
    member.stats = {}
  end
  
  #validate :email_for_cgg_ce
  before_save :strip_email
  before_create :reserve_ape_code
  
  def strip_email 
    self.email = self.email.strip.downcase
  end
  
  
#  validates_attachment_size :photo, :less_than => 2.megabytes if :resource_type == 'upload'
  has_attached_file :photo, 
    :default_url => "/assets/:class_default/:style/m.jpg",
    :storage => :s3,
    :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
    :path => "mp/:ape_code/:style/m.jpg",
    :url => "http://assets.civicevolution.org/mp/:ape_code/:style/m.jpg",
    :bucket => 'assets.civicevolution.org',
    :styles => {
      small: ['36x36#', :jpg],
      original: ['250x250>', :jpg]
    }  
  
  before_post_process :image?
                                
  attr_protected :photo_file_name, :photo_content_type, :photo_file_size
    
  def image?
    !(photo_content_type =~ /^image.*/).nil?
  end


  validate :password_non_blank, :on=>:update
  
  def self.email_in_use(email)
    member = self.find_by_email(email.downcase.strip)
    return member.nil? ? false : true
  end

  def self.authenticate(email, password)
    member = self.find_by_email(email.downcase.strip)
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
  
  def reserve_ape_code
    #if APP_NAME == 'app_2029' || Rails.env != 'production'
    #f self.domain == 'app_2029' || Rails.env != 'production'
      o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
      # I can check to make sure this code isn't already in the table    
      string = ''
      begin
        string  =  (1..14).map{ o[rand(o.length)]  }.join;
        dupl = Member.find_by_ape_code(string)
      end while not dupl.nil?
      self.ape_code = string  
    #else
    #  # FOR PRODUCTION APPS I WANT TO RESERVE AN id and ape_code from the master application: app_2029
    #  http = Net::HTTP.new('2029.civicevolution.org', 80)
    #  resp, data = http.get("/welcome/reserve_member_code?email=#{ URI.escape(self.email, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) }", nil )
    #  data  = JSON.parse data 
    #  logger.warn "id: #{data[0]['id']}, ape_code: #{data[0]['ape_code']}"
    #  self.id = data[0]['id']
    #  self.ape_code = data[0]['ape_code']
    #end
  end
  
  def team_titles
    if @team_titles.nil?
      #SELECT id, title from teams where id in (SELECT distinct team_id FROM participation_events WHERE member_id = 1 AND event_id < 100) ORDER BY title;	
      # any team I participate (comments, bs_ideas), endorse, follow, or joined
      #@team_titles = Team.select('id, title').where( 
      #  [%q|id IN (SELECT DISTINCT team_id FROM participation_events WHERE member_id = :member_id AND event_id < 100)|, {:member_id => self.id} ]
      #).order('title') 
      
      @team_titles = Team.find_by_sql(
        %Q|SELECT t.id, title, points_total FROM teams t, participant_stats ps where ps.member_id = #{self.id} 
        AND ps.team_id = t.id AND t.archived = false ORDER BY title|)
    end
    return @team_titles
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
  
  def self.gen_report(initiative_id)
    
    Member.find_by_sql([ %q|SELECT m.id, first_name, last_name, email,
      (SELECT COUNT(*) FROM participant_stats WHERE member_id = m.id) AS proposals,
      (SELECT COUNT(*) FROM comments WHERE member_id = m.id) AS comments,
      (SELECT COUNT(*) FROM ideas WHERE member_id = m.id) AS ideas,
      (SELECT SUM(points_total) FROM participant_stats WHERE member_id = m.id) AS total_points
      FROM members m, initiative_members im
      WHERE im.initiative_id = ? AND m.id = im.member_id
      ORDER BY first_name, last_name|, initiative_id ]
    )
    
  end  
  
  def o_type
    21 #type for member
  end
  def type_text
    'member' #type for member
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
