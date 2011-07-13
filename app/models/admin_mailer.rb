class AdminMailer < ActionMailer::Base

  self.default :from => "2029 and Beyond at CivicEvolution <support@civicevolution.org>",
    :reply_to => "support@civicevolution.org"
  
  def email_message(recipient, subject, plain_text_message, html_message)
    @plain_text_message = plain_text_message
    @html_message = html_message
    
    #attachments['invite.pdf'] = File.read("#{Rails.root}/public/pdf/EBD community invitation.pdf")
    mail(:to => "#{recipient.first_name} #{recipient.last_name} <#{recipient.email}>",
      :subject => subject
    )
  end


  #def email_message_with_attachment(recipient, subject, plain_text_message, html_message, include_bcc, sent_at = Time.now)
  #  subject    subject
  #  recipients "#{recipient.first_name} #{recipient.last_name} <#{recipient.email}>"
  #  from       "\"CivicEvolution\" <support@civicevolution.org>"
  #  sent_on    sent_at
  #  bcc       "support@auto.civicevolution.org" if include_bcc
  #  content_type    "multipart/mixed"
  #
  #  #part :content_type => "text/html",
  #  #  :body => render_message("html_email_with_attachment", :html_message => html_message)
  #
  #  #part :content => "text/plain", 
  #  #  :body => render_message("plain_text_email_with_attachment", :plain_text_message => plain_text_message)
  #
  #  part "text/plain" do |p|
  #    p.body = render_message("plain_text_email_with_attachment", :plain_text_message => plain_text_message)
  #    p.transfer_encoding = "base64"
  #  end
  #
  #
  #  attachment  "application/pdf" do |a|
  #    a.body = File.read(RAILS_ROOT + "/public/Participant information sheet - 2029 and Beyond interviews.pdf") 
  #    a.filename = "Participant information sheet - 2029 and Beyond interviews.pdf"  
  #  end
  #
  #end

end
