class ClientDebugMailer < ActionMailer::Base

  self.default :to => "Brian Sullivan <brian@civicevolution.org>"

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

  def preliminary_activity_failed(email, params, errors, host)
    @email = email
    @params = params
    @errors = errors
    @host = host

    mail(:subject => "Preliminary activity failed from host #{host}",
      :from => "Preliminary acitivity auditor <brian@civicevolution.org>")
  end

  def preliminary_activity_exception(email, params, message, backtrace, host)
    @email = email
    @params = params
    @message = message
    @backtrace = backtrace
    @host = host

    mail(:subject => "Preliminary activity exception from host #{host}",
      :from => "Preliminary acitivity auditor <brian@civicevolution.org>")
  end

end
