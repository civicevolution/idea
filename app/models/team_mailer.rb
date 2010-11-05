class TeamMailer < ActionMailer::Base
  
  def teammate_message(sender, recipient, subject, plain_text_message, host, mcode, team, sent_at = Time.now)
    subject    subject
    recipients "#{recipient.first_name} #{recipient.last_name} <#{recipient.email}>"
    from       "#{sender.first_name} #{sender.last_name} <team-messages@auto.civicevolution.org>"
    sent_on    sent_at
    body      :plain_text_message => plain_text_message, :host=>host, :mcode=>mcode, :team=>team, :sender=>sender
  end

  def teammate_message_receipt(sender, recips, subject, plain_text_message, host, mcode, team, sent_at = Time.now)
    subject    "Receipt copy of team message: #{subject}"
    recipients "#{sender.first_name} #{sender.last_name} <#{sender.email}>"
    from       "#{sender.first_name} #{sender.last_name} <team-messages@auto.civicevolution.org>"
    sent_on    sent_at
    body      :plain_text_message => plain_text_message, :host=>host, :mcode=>mcode, :team=>team, :sender=>sender, :recips=>recips
  end


end
