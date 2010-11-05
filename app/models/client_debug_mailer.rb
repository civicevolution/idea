class ClientDebugMailer < ActionMailer::Base
  

  def ape_restart(member, browser, host, sent_at = Time.now)
    subject    "APE RESTART detected for #{host}"
    recipients 'support@civicevolution.org'
    from       'support@civicevolution.org'
    sent_on    sent_at
    
    body       :member=>member, :browser=>browser
  end

  def report_filed(sent_at = Time.now)
    subject    'ClientDebugMailer#report_filed'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
