class ErrorMailer < ActionMailer::Base
  
  self.default :from => "Errors at CivicEvolution <support@civicevolution.org>",
    :reply_to => "support@civicevolution.org"

    def error_report(member, exception, host, app, sent_at = Time.now)
      @member = member
      @exception = exception
      @host = host
      @app = app

      mail(:to => "Brian Sullivan <brian@civicevolution.org>",
        :subject => "Server error on host #{host}"
      )
    end
  
  def delayed_job_error(job = {},error = {})
    @job = job
    @error = error
    
    mail(:to => "Brian Sullivan <brian@civicevolution.org>",
      :subject => "#{Rails.env} - Delayed Job error"
    )
  end


end
