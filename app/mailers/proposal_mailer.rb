class ProposalMailer < ActionMailer::Base
  before_create :set_initiative_parameters
  self.default :from => "CivicEvolution Support<suppprt@civicevolution.org>",
    :reply_to => "support@civicevolution.org"

  def submit_receipt(init_id, member, proposal)
    @member = member 
    @proposal = proposal

    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => 'Your proposal idea has been submitted for review',
      :template_path => @template_path, :template_name => @template_name
    )
  end

  def review_request(init_id, member, proposal)
    @member = member
    @proposal = proposal
    
    mail(:from => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :to => "Brian Sullivan <support@civicevolution.org>",
      :subject => "Please review this proposal idea for #{@app_name}",
      :reply_to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :template_path => @template_path, :template_name => @template_name
    )
  end
  
  def approval_notice(init_id, member, proposal, team)
    @member = member
    @proposal = proposal
    @team = team
    
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => "Your proposal idea has been approved and a proposal page has been created",
      :template_path => @template_path, :template_name => @template_name
    )
  end

  def report_approval(init_id, app_name, member, proposal, team)
    @member = member
    @proposal = proposal
    @team = team
    
    mail(:from => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => "New project just approved for #{app_name}",
      :to => "#{app_name} <support@civicevolution.org>",
      :reply_to => "#{member.first_name} #{member.last_name} <#{member.email}>"
    )
  end
  
  def team_join_confirmation(member, team, tr, host, sent_at = Time.now)
    @member = member
    @host = host
    @team = team
    @tr = tr
    mail(:to => "#{member.first_name} #{member.last_name} <#{member.email}>",
      :subject => "Thank you for joining a team with CivicEvolution"
    )
  end

  def team_send_invite(member, recipient, message, team, host, app_name, sent_at = Time.now)
    @member = member
    @recipient = recipient
    @message = message
    @team = team
    @host = host
    @app_name = app_name
    
    mail(:to => "#{recipient[:first_name]} #{recipient[:last_name]} <#{recipient[:email]}>",
      :subject => "#{member.first_name} #{member.last_name} has invited you to view a proposal for change at #{@app_name} @ CivicEvolution",
      :from => "#{@app_name} @ CivicEvolution <support@civicevolution.org>",
      :reply_to => "support@civicevolution.org"
    ) 
  end

  def send_participant_message(member, recipient, message, team, host, sent_at = Time.now)
    @member = member
    @recipient = recipient
    @message = message
    @team = team
    @host = host
    
    mail(:to => "#{recipient[:first_name]} #{recipient[:last_name]} <#{recipient[:email]}>",
      :subject => "#{member.first_name} #{member.last_name} has sent you a message about a 2029 and Beyond idea proposal",
      :from => "2029 and Beyond at CivicEvolution <support@civicevolution.org>",
      :reply_to => "support@civicevolution.org"
    ) 
  end

  def send_participant_message_copy(member, recipients, message, team, host, sent_at = Time.now)
    @member = member
    @recips = recipients
    @message = message
    @team = team
    @host = host

    mail(:to => "#{member[:first_name]} #{member[:last_name]} <#{member[:email]}>",
      :subject => "COPY: #{member.first_name} #{member.last_name} has sent you a message about a 2029 and Beyond idea proposal",
      :from => "2029 and Beyond at CivicEvolution <support@civicevolution.org>",
      :reply_to => "support@civicevolution.org"
    ) 
  end

  def review_team_summary_update(member, team, old_title, old_summary, host, app_name)
    @member = member
    @team = team
    @old_title = old_title
    @old_summary = old_summary
    @host = host
    @app_name = app_name
    
    mail(:to => "support@civicevolution.org",
      :subject => "Please review this proposal idea update from #{app_name}",
      :from => "2029 and Beyond at CivicEvolution <support@civicevolution.org>",
      :reply_to => "support@civicevolution.org"
    ) 
    
  end
  
  def review_update(member, team, field, old_ver, host, app_name, sent_at = Time.now)
    @member = member
    @team = team
    @field = field
    @old_ver = old_ver
    @host = host
    @app_name = app_name
    mail(:to => "Brian Sullivan <support@civicevolution.org>",
      :subject => "Please review this proposal idea update for #{app_name}"
    )
  end

  def team_just_launched(app_name, team, tr, host, sent_at = Time.now)
    @app_name = app_name
    @host = host
    @team = team
    @tr = tr
    mail(:to => "Brian Sullivan <support@civicevolution.org>",
      :subject => "A team was just launched for #{app_name}"
    )
  end


end
