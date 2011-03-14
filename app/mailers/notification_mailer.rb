class NotificationMailer < ActionMailer::Base
  

  def periodic_report(recip, team, comments, answers, bs_ideas, reports, mcode, sent_at = Time.now)
    @recip=recip
    @team=team
    @comments = comments
    @answers=answers
    @bs_ideas = bs_ideas
    @reports = reports
    @mcode = mcode
    mail(:to => "#{recip.first_name} #{recip.last_name} <#{recip.email}>",
      :subject => 'Your 2029 CivicEvolution proposal page has been updated',
      :from => "2029 and Beyond @ CivicEvolution <support@civicevolution.org>",
      :bcc => "support@auto.civicevolution.org",
      :date => sent_at
    )
  end



  def immediate_report(recip,team,report,entry,sent_at = Time.now)
    @recip=recip
    @team=team
    @report=report
    @entry=entry
    mail(:to => "#{recip.first_name} #{recip.last_name} <#{recip.email}>",
      :subject => 'Someone just posted in your 2029 CivicEvolution proposal page',
      :from => "2029 and Beyond @ CivicEvolution <support@civicevolution.org>",
      :bcc => "support@auto.civicevolution.org",
      :date => sent_at
    )
  end

  def settings_updated(sent_at = Time.now)
    subject    'NotificationMailer#settings_updated'
    recipients ''
    from       ''
    sent_on    sent_at
    
    body       :greeting => 'Hi,'
  end

end
