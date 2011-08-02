require 'bluecloth'
class GenericMailer < ActionMailer::Base
  
  def generic_email(member, recipient, subject, message, sent_at = Time.now)
    subject    subject
    recipients "#{recipient[:first_name]} #{recipient[:last_name]} <#{recipient[:email]}>"
    from       "\"Brian Sullivan\" <brian@civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :recipient => recipient, :subject => subject, :plain_text_message=>message, :html_message=>BlueCloth.new( message ).to_html
  end

end
