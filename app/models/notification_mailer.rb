class NotificationMailer < ActionMailer::Base
  

  def periodic_report(recip, team, comments, answers, bs_ideas, report,sent_at = Time.now)
    subject    'CivicEvolution team activity notification'
    recipients "#{recip.first_name} #{recip.last_name} <#{recip.email}>"
    from       "\"CivicEvolution notification\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :recip=>recip, :team=>team, :comments=>comments, :answers=>answers, :bs_ideas=>bs_ideas, :report=>report
  end

  def immediate_report(recip,team,report,entry,sent_at = Time.now)
    subject    'CivicEvolution immediate notification report'
    recipients "#{recip.first_name} #{recip.last_name} <#{recip.email}>"
    from       "\"CivicEvolution notification\" <no-reply@auto.civicevolution.org>"
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
