class ClientDebugMailer < ActionMailer::Base
  

  def ape_failure(member, failure, browser, host, sent_at = Time.now)
    subject    "APE FAILURE: #{failure} detected for #{host}"
    recipients 'support@civicevolution.org'
    from       'support@civicevolution.org'
    sent_on    sent_at
    
    body       :member=>member, :failure=>failure, :browser=>browser
  end

  def report_filed(sent_at = Time.now)
    subject    'ClientDebugMailer#report_filed'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
