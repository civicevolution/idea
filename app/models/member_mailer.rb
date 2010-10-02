class MemberMailer < ActionMailer::Base

  def confirm_registration(member, mcode, host, app_name, sent_at = Time.now)
    subject    'Confirm your CivicEvolution registration'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <confirm@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :mcode => mcode, :host => host, :app_name => app_name
  end

  def reset_password(member, mcode, host, sent_at = Time.now)
    subject    'Reset your CivicEvolution password'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :mcode => mcode, :host => host
  end

end
