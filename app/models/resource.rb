class Resource < ActiveRecord::Base

  belongs_to :comment

  validates_length_of :title, :in => 5..250, :allow_blank => false
  validate :check_length
  validate :valid_resource?
  
  validates_presence_of :member_id
  validates_presence_of :comment_id
  
  validates_attachment_size :resource, :less_than => 2.megabytes if :resource_type == 'upload'
  has_attached_file :resource,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "res/:res_base/:id/:style/:basename.:extension",
    :url => "http://assets.civicevolution.org/res/:res_base/:id/:style/:basename.:extension",
    :bucket => 'assets.civicevolution.org',
    :styles => { :small => '50x50>' }  

  
  before_post_process :image?
                                
  attr_accessible :comment_id, :member_id, :title, :description, :link_url, :resource_file_name, :resource_file_size, :resource_content_type, :resource_size
  
  
  attr_accessor :resource_type
  attr_accessor :team_id
  
  def check_length
    if self.team_id && self.team_id > 0
      range = Team.find(self.team_id).res_criteria
      range = range.match(/(\d+)..(\d+)/)
      errors.add(:description, "must be at least #{range[1]} characters") unless description && description.length >= range[1].to_i
      errors.add(:description, "must be no longer than #{range[2]} characters") unless description && description.length <= range[2].to_i
    end
  end  
  
private  

  def image?
    
    !(resource_content_type =~ /^image.*/).nil?
  end

  def valid_resource?
    # either url or file_name, size, type
      
    if resource_file_name && resource_file_name.length > 0 && link_url && link_url.length > 0 
      logger.debug "RRR Both url and file_name are defined"
      errors.add(:form, 'cannot upload a file and reference a website, you must choose one or the other')
      errors.add(:link_url, "is not allowed if you wish to upload a file")
      errors.add(:resource_file_name, "is not allowed if you wish to link to a website")
    end
    
    if resource_type == 'upload' && (!resource_file_name || resource_file_name.length == 0)
      #errors.add(:form, 'specify a file to upload')
      #errors.add(:resource, "is required to upload a file")
      errors.add(:resource, "must be selected")
    end

    if resource_type == 'link' && ( !link_url || link_url !~ /^https?:\/\/.+\..+/ )
      #errors.add(:form, 'must reference a website or upload a file')
      errors.add(:link_url, "must be a valid link to a website that begins with http:// or https://")
    end
    
#    if url.length > 1 && url !~ /^https?:\/\//
#      logger.debug "url is bad"
#      errors.add(:url, "must begin with http:// or https://")
#    end
#    
  end

end
