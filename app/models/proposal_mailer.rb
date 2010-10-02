class ProposalMailer < ActionMailer::Base
  

  def submit_receipt(member, proposal, app_name, sent_at = Time.now)
    subject    'Your proposal idea has been submitted for review'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :proposal => proposal, :app_name=>app_name
  end

  def review_request(member, proposal, host, app_name, sent_at = Time.now)
    subject    'Please review this proposal idea'
    recipients 'support@civicevolution.org'
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :proposal => proposal, :host=>host, :app_name=>app_name
  end

  def approval_notice(member, proposal, team, host, sent_at = Time.now)
    subject    'Your proposal idea has been approved and published'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :proposal => proposal, :host => host, :team => team
  end

  def team_join_confirmation(member, team, tr, host, sent_at = Time.now)
    subject    'Thank you for joining a team with CivicEvolution'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :host => host, :team => team, :tr => tr
  end

  def team_workspace_available(member, team, host, sent_at = Time.now)
    subject    'A CivicEvolution proposal workspace has been created for your team'
    recipients "#{member.first_name} #{member.last_name} <#{member.email}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :host => host, :team => team
  end

  def team_send_invite(member, recipient, invite, team, host, sent_at = Time.now)
    subject    "#{member.first_name} #{member.last_name} has invited you to view a proposal for change at CivicEvolution"
    recipients "#{recipient[:first_name]} #{recipient[:last_name]} <#{recipient[:email]}>"
    from       "\"CivicEvolution\" <no-reply@auto.civicevolution.org>"
    sent_on    sent_at
    
    body       :member => member, :recipient => recipient, :invite => invite, :team => team, :host => host
  end



end
