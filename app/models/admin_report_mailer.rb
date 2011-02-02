class AdminReportMailer < ActionMailer::Base
  
  def report_content(report, item_text, item, host, app, sent_at = Time.now)
    subject    "Content report from host #{host}"
    recipients "Brian Sullivan <brian@civicevolution.org>"
    from       "Content report <brian@civicevolution.org>"
    sent_on    sent_at
    
    body       :report => report, :item_text=>item_text, :item=> item, :host => host, :app=>app
  end


end
