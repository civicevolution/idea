class PreliminaryParticipantActivity < ActiveRecord::Base
  serialize :flash_params
  
  before_create :trim_email
  
  def trim_email
    self.email = self.email.strip.downcase unless self.email.nil?
  end
end
