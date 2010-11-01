class AdminMailer < ActionMailer::Base

  def email_message(recipient, subject, plain_text_message, html_message, sent_at = Time.now)
    subject    subject
    recipients "#{recipient.first_name} #{recipient.last_name} <#{recipient.email}>"
    from       "\"CivicEvolution\" <support@civicevolution.org>"
    sent_on    sent_at
    
    body      :plain_text_message => plain_text_message, :html_message => html_message
  end

  def reset_password(member, mcode, host, sent_at = Time.now)
    subject    'Reset your CivicEvolution password'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :mcode => mcode, :host => host
  end

end
