class ErrorMailer < ActionMailer::Base
  
  def error_report(member, exception, host, app, sent_at = Time.now)
    subject    "Server error on host #{host}"
    recipients "Brian Sullivan <brian@civicevolution.org>"
    from       "Server error report <brian@civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :exception => exception, :host => host, :app=>app
  end


end
