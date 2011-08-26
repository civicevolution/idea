class AdminReportMailer < ActionMailer::Base
  
  self.default :to => "Brian Sullivan <brian@civicevolution.org>"

  
  def report_content(report, target, host, app)
    @report = report
    @target = target
    @host = host
    @app = app
    
    mail(:subject => "Content report from host #{host}",
      :from => "Content report <brian@civicevolution.org>")
  end

  def submit_proposal(submit_request, team, member, host, app)
    @submit_request = submit_request
    @team = team
    @member = member
    @host = host
    @app = app
    
    mail(:subject => "Proposal submit request from host #{host}",
      :from => "Submit proposal <brian@civicevolution.org>")
  end
  
end
