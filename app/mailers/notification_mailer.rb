class NotificationMailer < ActionMailer::Base
  

  def periodic_report(recip, app, teams, ideas, comments, answers, talking_points, reports, mcode,sent_at = Time.now)
    @recip=recip
    @teams=teams
    @ideas = ideas
    @comments = comments
    @answers=answers
    @talking_points = talking_points
    @reports = reports
    @mcode = mcode
    mail(:to => "#{recip.first_name} #{recip.last_name} <#{recip.email}>",
      :subject => "Your #{app} CivicEvolution proposal has been updated",
      :from => "#{app} at CivicEvolution <support@civicevolution.org>",
      :date => sent_at
    )
  end



  def immediate_report(recip, app, team,report,entry,mcode,host,sent_at = Time.now)
    @recip=recip
    @team=team
    @report=report
    @entry=entry
    @mcode=mcode
    @host=host
    mail(:to => "#{recip.first_name} #{recip.last_name} <#{recip.email}>",
      :subject => "Someone just posted in your #{app} CivicEvolution proposal",
      :from => "#{app} at CivicEvolution <support@civicevolution.org>",
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
