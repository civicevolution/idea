# config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false
#Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 6
#Delayed::Worker.max_run_time = 5.minutes
#Delayed::Worker.delay_jobs = !Rails.env.test?

module Delayed
  class Worker
    alias_method :original_handle_failed_job, :handle_failed_job
    alias_method :original_failed, :failed
    
    protected
    def handle_failed_job(job, error)
      begin
        if job.attempts.to_i == 1
          #say "Error Intercepted by Hoptoad..."
          #notify_airbrake(exception) unless Rails.env == 'development'
          
          say "An email was sent to notify about delayed_job FIRST failure in Delayed::Worker::handle_failed_job" 
          ErrorMailer.delayed_job_error(job,error).deliver
        end
      rescue
      end
      original_handle_failed_job(job,error)
    end

    def failed(job)
      begin
        say "An email was sent to notify about delayed_job FINAL failure in Delayed::Worker::failed"
        ErrorMailer.delayed_job_error(job).deliver
      rescue
      end
      original_failed(job)
    end

  end
end
