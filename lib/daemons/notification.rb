#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

last_pending_report_hour_processed = Time.now.utc.hour # start from this hour
logger = ActiveSupport::BufferedLogger.new( File.dirname(__FILE__) + "/../../log/notification.rb.log" )

# this is old code for dealing with multipart emails in Rails 2.3.5 - not sure if this is still an issue
#av = ActionView::Base.new(Rails::Configuration.new.view_path)
#
## implicit multipart only works from the rails root directory (https://rails.lighthouseapp.com/projects/8994/tickets/2263)
#FileUtils.cd Rails.root
#
##ActiveRecord::Base.logger.info "\n Rails::Configuration.new.view_path: #{Rails::Configuration.new.view_path}\n"
#

$running = true
Signal.trap("TERM") do 
  $running = false
end

Signal.trap("USR1") do 
  #logger.debug "Received USR1 signal at #{Time.now}."
  # I want to execute this call in a few seconds to make sure the data is available in the db
  # I might add logic to try again if the data is not found
  # Does this sleep in the trap add overhead?
  sleep 3
  logger.debug "TRAP [USR1] call ImmediateNotificationRequest.check_team_content_log at #{Time.now} in ENV: #{ENV["RAILS_ENV"]}.\n"
  NotificationRequest.check_team_content_log(logger)
end

Signal.trap("USR2") do 
  #logger.debug "Received USR2 signal at #{Time.now}."
  #logger.debug "Force queue of pending reports."

  hour = Time.now.utc.hour 
  dow = Time.now.utc.wday
  sleep 8
  logger.debug "TRAP [USR2] LOOP queue pending reports for dow: #{dow} and hour: #{hour} at #{Time.now}.\n"
  NotificationRequest.send_periodic_report(dow,hour,logger)

end

logger.debug "entering the run loop"


while($running) do
  
  # Replace this with your code
  #Rails.logger.auto_flushing = true
  #Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  #sleep 10
  
  logger.auto_flushing = true
  logger.info "This notification.rb is still running at #{Time.now}.\n"
  
  #logger.debug "LOOP call NotificationRequest.check_team_content_log at #{Time.now} in ENV: #{ENV["RAILS_ENV"]}.\n"
  NotificationRequest.check_team_content_log(logger)
  
  # Look at the time and find out if it is a new hour
  hour = Time.now.utc.hour # have the reports for this hour been run?
  if hour != last_pending_report_hour_processed
    # the current hour is not the same as the hour the reports were last processed
    dow = Time.now.utc.wday
    logger.debug "LOOP queue pending reports for dow: #{dow} and hour: #{hour} at #{Time.now}.\n"
    NotificationRequest.send_periodic_report(dow,hour,logger)
    last_pending_report_hour_processed = hour
  end
  
  sleep 60
  
end