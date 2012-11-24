class MemberMailer < ActionMailer::Base
  
  self.default :reply_to => "support@civicevolution.org"
  

  def confirm_registration(member, mcode, host, app_name, sent_at = Time.now)
    @member = member
    @mcode = mcode
    @host = host
    @app_name = app_name
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'Confirm your CivicEvolution registration',
      :from => "#{app_name} <support@civicevolution.org>"
    )
  end

  def report_signup(email, url, app_name, sent_at = Time.now)
    @email = email
    @url = url
    @app_name = app_name
    mail(:from => "New member <#{@email}>",
      :subject => 'New member just signed up for CivicEvolution',
      :to => "#{app_name} <support@civicevolution.org>",
      :reply_to => "#{@email}"
    )
  end

  def report_confirmation(member, app_name, sent_at = Time.now)
    @member = member
    @app_name = app_name
    mail(:from => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'New member just confirmed CivicEvolution registration',
      :to => "#{app_name} <support@civicevolution.org>",
      :reply_to => "#{member.first_name} #{member.last_name} <#{member.email}>"
    )
  end

  def reset_password(member, mcode, host, sent_at = Time.now)
    @member = member
    @mcode = mcode
    @host = host
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'Reset your CivicEvolution password',
      :from => "CivicEvolution <support@civicevolution.org>"
    )
  end
  

  def new_access_code(member, uri, host, sent_at = Time.now)
    @member = member
    @uri = uri
    @host = host
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'Resend email with valid access code',
      :from => "CivicEvolution <support@civicevolution.org>"
    )
  end

  def send_profile_link(email, url, app_name)
    @email = email
    @url = url
    @app_name = app_name
    mail(:to => email,
      :subject => 'Please create your CivicEvolution membership',
      :from => "#{app_name} <support@civicevolution.org>"
    )
  end


end
