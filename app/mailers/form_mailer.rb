class FormMailer < ActionMailer::Base
  
  def submitted_form_receipt(member, form_data, sent_at = Time.now)
    subject    "Your workshop proposal has been received"
    recipients "#{member[:first_name]} #{member[:last_name]} <#{member[:email]}>"
    from       "Brian Sullivan <brian@civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :form_data => form_data
  end

  def forward_submitted_form(member, form_data, host, sent_at = Time.now)
    subject    "Please review this workshop proposal"
    recipients "Brian Sullivan <brian@civicevolution.org>"
    from       "Brian Sullivan <brian@civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :form_data => form_data, :host=> host
  end

  

end
