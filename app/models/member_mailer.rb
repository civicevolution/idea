class MemberMailer < ActionMailer::Base
  
  self.default :from => "2029 and Beyond @ CivicEvolution <support@civicevolution.org>",
    :reply_to => "support@civicevolution.org"
  

  def confirm_registration(member, mcode, host, app_name, sent_at = Time.now)
    @member = member
    @mcode = mcode
    @host = host
    @app_name = app_name
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'Confirm your CivicEvolution registration'
    )
  end

  def reset_password(member, mcode, host, sent_at = Time.now)
    @member = member
    @mcode = mcode
    @host = host
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'Reset your CivicEvolution password'
    )
  end
  

  def new_access_code(member, uri, host, sent_at = Time.now)
    @member = member
    @uri = uri
    @host = host
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'Resend email with valid access code'
    )
  end


end
