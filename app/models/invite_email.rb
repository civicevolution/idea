class InviteEmail < Tableless
  column :message,       :text
  column :recipient_emails, :text
  
  attr_accessor :sender
  
  attr_accessor :recipients
  
  validates_presence_of  :message, :recipient_emails
  validates_length_of :message, :in => 10..1000, :message=>'seems too short, at least 10 characters'
  
  #validates_presence_of  :name, :email_address, :message
  before_validation :process_recipient_emails
  validate :check_recipient_email_addresses

  
  
  #validates_format_of    :email_address,
  #                       :with => %r{\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z}i, :message => "should be like xxx@yyy.zzz"
                         
                         
                         
                         
  def process_recipient_emails                       
    logger.debug "process_recipient_emails #{self.recipient_emails}"
    self.recipients = []
    # break this into lines. process each line, record errors
    
    lines = self.recipient_emails.split(/[\n\r]+/)
    lines.each do |line|
      recipient = {}
      logger.debug "extract and verify email recipient in text: #{line}"
      pieces = line.match(/(.*) ([^ ]*)/)
      if pieces.nil? # no space, treat as just an email address
        recipient[:email] = line
      else
        recipient[:email] = pieces[2]
        name = pieces[1]
        pieces = name.match(/(.*) (.*)/)
        if pieces.nil? # no space, treat as just one name
          recipient[:first_name] = name
        else
          recipient[:first_name] = pieces[1]
          recipient[:last_name] = pieces[2]
        end        
      end
      self.recipients.push recipient
      logger.debug "recipient: #{recipient.inspect}"
    end
  end
                         
  def check_recipient_email_addresses
    addresses = {}
    logger.debug "check_recipient_email_addresses"
    self.recipients.each do |recipient|
      logger.debug "verify email address for #{recipient.inspect}"
      if recipient[:email].match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i).nil?
        errors.add(:recipient_emails, "should be like xxx@yyy.zzz")
        recipient[:error] = "The recipient must include a valid email address like xxx@yyy.zzz"
      elsif ! addresses[recipient[:email]].nil?
        errors.add(:recipient_emails, "should be like xxx@yyy.zzz")
        recipient[:error] = "Email is a duplicate in this list"
      end
      addresses[recipient[:email]] = 1
    end
    
    
  end
  
end #class