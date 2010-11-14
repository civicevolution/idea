#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.logger.info "Started daemon at #{Time.now} in ENV: #{ENV["RAILS_ENV"]}.\n"
av = ActionView::Base.new(Rails::Configuration.new.view_path)

# implicit multipart only works from the rails root directory (https://rails.lighthouseapp.com/projects/8994/tickets/2263)
FileUtils.cd Rails.root

#ActiveRecord::Base.logger.info "\n Rails::Configuration.new.view_path: #{Rails::Configuration.new.view_path}\n"

#last_pending_report_hour_processed = ActiveRecord::Base.connection.select_value( "SELECT extract(hour from created_at) from pending_reports order by id DESC limit 1").to_i

last_pending_report_hour_processed = Time.now.utc.hour # start from this hour

$running = true
Signal.trap("TERM") do 
  $running = false
end

Signal.trap("USR1") do 
  ActiveRecord::Base.logger.info "Received USR1 signal at #{Time.now}."
  # I want to execute this call in a few seconds to make sure the data is available in the db
  # I might add logic to try again if the data is not found
  # Does this sleep in the trap add overhead?
  sleep 3
  ActiveRecord::Base.logger.info "TRAP call ImmediateNotificationRequest.check_team_content_log at #{Time.now} in ENV: #{ENV["RAILS_ENV"]}.\n"
  NotificationRequest.check_team_content_log(ActiveRecord::Base.logger)
end

Signal.trap("USR2") do 
  ActiveRecord::Base.logger.info "Received USR2 signal at #{Time.now}."
  ActiveRecord::Base.logger.info "Force queue of pending reports."

  hour = Time.now.utc.hour 
  dow = Time.now.utc.wday
  ActiveRecord::Base.logger.info "LOOP queue pending reports for dow: #{dow} and hour: #{hour} at #{Time.now}.\n"
  NotificationRequest.send_periodic_report(dow,hour)

end



while($running) do
  ActiveRecord::Base.logger.info "LOOP call NotificationRequest.check_team_content_log at #{Time.now} in ENV: #{ENV["RAILS_ENV"]}.\n"
  NotificationRequest.check_team_content_log(ActiveRecord::Base.logger)
  
  # Look at the time and find out if it is a new hour
  hour = Time.now.utc.hour # have the reports for this hour been run?
  if hour != last_pending_report_hour_processed
    # the current hour is not the same as the hour the reports were last processed
    dow = Time.now.utc.wday
    ActiveRecord::Base.logger.info "LOOP queue pending reports for dow: #{dow} and hour: #{hour} at #{Time.now}.\n"
    NotificationRequest.send_periodic_report(dow,hour)
    last_pending_report_hour_processed = hour
  end
  
  sleep 5
end # end of while running
