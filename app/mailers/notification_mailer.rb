class NotificationMailer < ActionMailer::Base
  

  def periodic_report(recip, teams, comments, answers, talking_points, reports, mcode,sent_at = Time.now)
    @recip=recip
    @teams=teams
    @comments = comments
    @answers=answers
    @talking_points = talking_points
    @reports = reports
    @mcode = mcode
    mail(:to => "#{recip.first_name} #{recip.last_name} <#{recip.email}>",
      :subject => 'Your 2029 CivicEvolution proposal has been updated',
      :from => "2029 and Beyond at CivicEvolution <support@civicevolution.org>",
      :date => sent_at
    )
  end



  def immediate_report(recip,team,report,entry,mcode,host,sent_at = Time.now)
    @recip=recip
    @team=team
    @report=report
    @entry=entry
    @mcode=mcode
    @host=host
    mail(:to => "#{recip.first_name} #{recip.last_name} <#{recip.email}>",
      :subject => 'Someone just posted in your 2029 CivicEvolution proposal',
      :from => "2029 and Beyond at CivicEvolution <support@civicevolution.org>",
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
