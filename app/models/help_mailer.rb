class HelpMailer < ActionMailer::Base
  
  def help_request_receipt(member, help_request, client_details, sent_at = Time.now)
    subject    "Your request for help has been received by CivicEvolution"
    recipients "#{member[:first_name]} #{member[:last_name]} <#{member[:email]}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :help_request => help_request, :client_details => client_details
  end


  def help_request_review(member, help_request, client_details, host, app, sent_at = Time.now)
    subject    "Please review this request for help at CivicEvolution"
    recipients "CivicEvolution Admin <support@civicevolution.org>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :help_request => help_request, :client_details => client_details, :host=> host, :app=> app
  end
  

end
