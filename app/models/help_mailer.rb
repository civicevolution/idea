class HelpMailer < ActionMailer::Base
  
  def help_request_receipt(member, help_request, client_details)
    @member = member
    @help_request = help_request
    @client_details = client_details
    
    mail(:to => "#{member[:first_name]} #{member[:last_name]} <#{member[:email]}>",
      :subject => "Your request for help has been received by CivicEvolution",
      :from => "2029 and Beyond @ CivicEvolution <support@civicevolution.org>",
      :reply_to => "support@civicevolution.org"
    ) 
  end


  def help_request_review(member, help_request, client_details, host, app)
    @member = member
    @help_request = help_request
    @client_details = client_details
    @host = host
    @app = app

    mail(:to => "CivicEvolution Admin <support@civicevolution.org>",
      :subject => "Please review this request for help at CivicEvolution",
      :from => "2029 and Beyond @ CivicEvolution <support@civicevolution.org>",
      :reply_to => "support@civicevolution.org"
    ) 
  end
  

end
