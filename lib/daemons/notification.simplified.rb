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


$running = true
Signal.trap("TERM") do 
  $running = false
end

Signal.trap("USR1") do 
  ActiveRecord::Base.logger.info "Received USR1 signal at #{Time.now}."
  # I want to execute this call in a few seconds to make sure the data is available in the db
  # I might add logic to try again if the data is not found
  # Does this sleep in the trap add overhead?
  #sleep 3
  #ActiveRecord::Base.logger.info "TRAP call ImmediateNotificationRequest.check_team_content_log at #{Time.now} in ENV: #{ENV["RAILS_ENV"]}.\n"
  #ImmediateNotificationRequest.check_team_content_log(ActiveRecord::Base.logger)
  
  ActiveRecord::Base.logger.info "send emailReceived USR1 signal at #{Time.now}."
  m = Member.find(1)
  NotificationMailer.deliver_immediate_report(m, nil, nil, nil)
  ActiveRecord::Base.logger.info "email sent Received USR1 signal at #{Time.now}."
  
end




while($running) do
  ActiveRecord::Base.logger.info "LOOP call ImmediateNotificationRequest.check_team_content_log at #{Time.now} in ENV: #{ENV["RAILS_ENV"]}.\n"
  #ImmediateNotificationRequest.check_team_content_log(ActiveRecord::Base.logger)
  
  logger = ActiveRecord::Base.logger
  
  
  logger.info "\n 00000000000000000 ImmediateNotificationRequest check_team_content_log at #{Time.now}."

  new_logs = TeamContentLog.all(:conditions=>'processed=false',:limit=>50)
  if new_logs.size>0
    new_logs.each do |log_record|
      team = entry = nil
      ImmediateNotificationRequest.find_report_recipients(log_record).each do |report|
        #ActiveRecord::Base.logger.info "\n I found a match\n"
        logger.info "\n 11111111111111111111111 ImmediateNotificationRequest I found a match #{report[:member_id]}\n"

        recipient = Member.first(:select=>'first_name, last_name, email', :conditions=>{:id=>report[:member_id]})
        logger.info "\n 2222222222222222222222222222 ImmediateNotificationRequest Send an email to #{recipient.email} at #{Time.now}."

        # now send an email
        team ||= Team.first(:select=>'id, title', :conditions=> {:id=>report[:team_id]} )
        #logger.info "Send an team to #{team.title} at #{Time.now}."
        if report[:report_type] == 'full'
          # make sure I have the necessary data for a full report
          case
            when report[:o_type] ==  2
              entry ||= Answer.find(report[:o_id])
            when report[:o_type] ==  3
              entry ||= Comment.first(
                :select => 'c.id, text, c.updated_at, first_name, last_name',
                :conditions => { 'c.id'=>report[:o_id]},
                :joins => 'as c inner join members as m on m.id = c.member_id' 
              )
            when report[:o_type] ==  11
              entry ||= BsIdea.find(report[:o_id])
          end # end case
        end # end if full

        logger.info "\n 3333333333333333333333333333 ImmediateNotificationRequest Send an email for entry #{entry.inspect} at #{Time.now}."        
        #av = ActionView::Base.new(Rails::Configuration.new.view_path)
        #html = av.render :partial=>'notification/immediate_report', :locals=>{:recip=>recipient, :report=>report, :entry=>entry}
        #logger.info "\n 3333333333AAAAAAAAA ImmediateNotificationRequest html: #{html} sent to #{recipient.email} at #{Time.now}."
        
        
        NotificationMailer.deliver_immediate_report(recipient, team, report, entry)
        logger.info "\n 44444444444444444444444 ImmediateNotificationRequest Email sent to #{recipient.email} at #{Time.now}."

      end # end each report
      logger.info "\n 555555555555555555555 ImmediateNotificationRequest update log_record as processed at #{Time.now}."        
      log_record.processed = true
      log_record.save

    end # end each log_record
  end
  logger.info "\n 66666666666666666 ImmediateNotificationRequest EXIT  check_team_content_log at #{Time.now}."        
  
  
  
  
  
  sleep 10
end # end of while running
