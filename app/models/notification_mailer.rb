class NotificationMailer < ActionMailer::Base
  

  def periodic_report(recip, team, comments, answers, bs_ideas, reports, mcode, sent_at = Time.now)
    subject    'Your 2029 CivicEvolution team has been working'
    recipients "#{recip.first_name} #{recip.last_name} <#{recip.email}>"
    from       "CivicEvolution <no-reply@auto.civicevolution.org>"
    bcc        "support@auto.civicevolution.org"
    sent_on    sent_at
    
    body       :recip=>recip, :team=>team, :comments=>comments, :answers=>answers, :bs_ideas=>bs_ideas, :reports=>reports, :mcode=>mcode
  end

  def immediate_report(recip,team,report,entry,sent_at = Time.now)
    subject    'Someone just posted in your 2029 CivicEvolution team'
    recipients "#{recip.first_name} #{recip.last_name} <#{recip.email}>"
    from       "CivicEvolution <no-reply@auto.civicevolution.org>"
    bcc         "support@auto.civicevolution.org"
    sent_on    sent_at
    
    
    body       :recip=>recip, :team=>team, :report=>report, :entry=>entry
  end

  def settings_updated(sent_at = Time.now)
    subject    'NotificationMailer#settings_updated'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
