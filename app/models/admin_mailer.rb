class AdminMailer < ActionMailer::Base

#  def email_message(recipient, subject, plain_text_message, html_message, include_bcc, sent_at = Time.now)
#    subject    subject
#    recipients "#{recipient.first_name} #{recipient.last_name} <#{recipient.email}>"
#    from       "\"2029 and Beyond @ CivicEvolution\" <support@civicevolution.org>"
#    sent_on    sent_at
#    bcc       "support@auto.civicevolution.org" if include_bcc
#    body      :plain_text_message => plain_text_message, :html_message => html_message
#  end

  def email_message(recipient, subject, plain_text_message, html_message, include_bcc)
    @plain_text_message = plain_text_message
    @html_message = html_message
    
    mail(:to => "#{recipient.first_name} #{recipient.last_name} <#{recipient.email}>",
      :subject => subject,
      :from => "2029 and Beyond @ CivicEvolution <support@civicevolution.org>",
      :reply_to => "support@civicevolution.org",
      :bcc => include_bcc ? "support@auto.civicevolution.org" : ''
    ) do |format|
      format.text
      format.html
    end
  end


  def email_message_with_attachment(recipient, subject, plain_text_message, html_message, include_bcc, sent_at = Time.now)
    subject    subject
    recipients "#{recipient.first_name} #{recipient.last_name} <#{recipient.email}>"
    from       "\"CivicEvolution\" <support@civicevolution.org>"
    sent_on    sent_at
    bcc       "support@auto.civicevolution.org" if include_bcc
    content_type    "multipart/mixed"

    #part :content_type => "text/html",
    #  :body => render_message("html_email_with_attachment", :html_message => html_message)

    #part :content => "text/plain", 
    #  :body => render_message("plain_text_email_with_attachment", :plain_text_message => plain_text_message)

    part "text/plain" do |p|
      p.body = render_message("plain_text_email_with_attachment", :plain_text_message => plain_text_message)
      p.transfer_encoding = "base64"
    end
  

    attachment  "application/pdf" do |a|
      a.body = File.read(RAILS_ROOT + "/public/Participant information sheet - 2029 and Beyond interviews.pdf") 
      a.filename = "Participant information sheet - 2029 and Beyond interviews.pdf"  
    end
  
  end



  def reset_password(member, mcode, host, sent_at = Time.now)
    subject    'Reset your CivicEvolution password'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :mcode => mcode, :host => host
  end

end
