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
  sleep 3
  CeDaemons.check_team_content_log()
end

module CeDaemons
  def self.check_team_content_log
    # check if there are any new immediate records and process them
    ActiveRecord::Base.logger.info "check_team_content_log at #{Time.now}."
  
    new_logs = TeamContentLog.all(:conditions=>'processed=false',:limit=>50)
    if new_logs.size>0
      new_logs.each do |log_record|
        team = entry = nil
        ImmediateNotificationRequest.find_report_recipients(log_record).each do |report|
          #ActiveRecord::Base.logger.info "\n I found a match\n"
          ActiveRecord::Base.logger.info "\n XXXXXXXXXXXXXXXXXXXXXXXX I found a match #{report[:member_id]}\n"
        
          recipient = Member.first(:select=>'first_name, last_name, email', :conditions=>{:id=>report[:member_id]})
          ActiveRecord::Base.logger.info "\nYYYYYYYYYYYYYYYYYYYYYYYY Send an email to #{recipient.email} at #{Time.now}."
        
          # now send an email
          team ||= Team.first(:select=>'id, title', :conditions=> {:id=>report[:team_id]} )
          #ActiveRecord::Base.logger.info "Send an team to #{team.title} at #{Time.now}."
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
        
          ActiveRecord::Base.logger.info "\nZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ Send an email for entry #{entry.inspect} at #{Time.now}."        
        
          #html = av.render :partial=>'notification/immediate_report', :locals=>{:recip=>recipient, :report=>report, :entry=>entry}
        
          NotificationMailer.deliver_immediate_report(recipient, team, report, entry)
          ActiveRecord::Base.logger.info "\nOOOOOOOOOOOOOOOOOOOOOOOOOOOO Email sent to #{recipient.email} at #{Time.now}."
  
        end # end each report
        ActiveRecord::Base.logger.info "\nKKKKKKKKKKKKKKKKKKKKKKK update log_record as processed at #{Time.now}."        
        log_record.processed = true
        log_record.save
      
      end # end each log_record
    end
  end
  ActiveRecord::Base.logger.info "\nIIIIIIIIIIIIIIIIIIIIII Exit CeModule at #{Time.now}."
end # end module CeDaemons



while($running) do
  
  CeDaemons.check_team_content_log()
  
  sleep 30
end # end of while running
