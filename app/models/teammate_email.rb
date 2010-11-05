class TeammateEmail < Tableless
  # like invite_email.rb
  column :message,       :text
  
  attr_accessor :subject
  attr_accessor :recip_ids
  attr_accessor :sender
  
  validates_length_of  :subject, :minimum => 5, :message=>"must be at least 5 characters long"
  validates_length_of  :subject, :maximum => 255, :message=>"must be less than 255 characters long"
  validates_presence_of :recip_ids, :message=>"Please select at least one recipient"
  validates_length_of :message, :minimum => 10, :message=>'must be at least least 10 characters long'
  validates_length_of :message, :maximum => 2500, :message=>'must be less than 2500 characters'

  
end #class