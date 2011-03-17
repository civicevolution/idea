class NotificationController < ApplicationController

  
  
  def settings
    @teams = TeamRegistration.my_teams(@member.id)
    @notification_setting = nil
    if @teams.size > 0
      @team_id = params[:id] 
      if @team_id.nil? || @teams.detect{|t| t.id == @team_id.to_i}.nil? 
        @team_id = @teams[0].id
        # redirect with specified team_id
        redirect_to :action=>'settings', :id=>@team_id
        return 
      end
      #@teams = @teams.map{|t| [t.title.slice(0..50), t.id]}
      @teams = @teams.map{|t| [t.title, t.id]}
      @notification_setting = NotificationRequest.new :member_id=>@member.id, :team_id=>@team_id, :act=>'init'
    end
    render :action=>'settings', :layout=>'welcome'
  end

  def update_notification_settings
    logger.debug "update_notification_settings params: #{params.inspect}"
    @notification_setting = NotificationRequest.new :member_id=>@member.id, :act=>'split_save'
    @notification_setting.attributes = params[:notification_setting]        
    @saved = @notification_setting.split_n_save  

    render :action=>'update_notification_settings', :layout=>'welcome'
    #render :action=>'settings', :layout=>'welcome'
  end
  
  def run_test
    case params[:type]
      when 'immediate'
        Process.kill("USR1", IO.read(Rails.root + 'log/notification.rb.pid').chomp.to_i )        
      when 'hourly'
        Process.kill("USR2", IO.read(Rails.root + 'log/notification.rb.pid').chomp.to_i )
      when 'clear'
        TeamContentLog.update_all("processed=false","team_id=#{params[:team_id]}", :limit=>params[:num_records], :order=>'id DESC')
    end
  end
  
  def check_log
    logger.debug "Check team content log"
    NotificationRequest.check_team_content_log
  end
  
  def check_periodic
    @reports = NotificationRequest.send_periodic_report || []
  end
  
  def periodic_report
    logger.debug "send periodic report"
    hour = Time.now.utc.hour 
    dow = Time.now.utc.wday
    logger.info " queue pending reports for dow: #{dow} and hour: #{hour} at #{Time.now}.\n"
    NotificationRequest.send_periodic_report(dow,hour)
  end
  
  def send_immediate
    
    log = TeamContentLog.find(params[:id])
    log.processed = false
    log.save
    
    NotificationRequest.check_team_content_log(logger)
    render :text=>'NotificationRequest.check_team_content_log(logger) was called'
  end
  
  def send_periodic
    
    req = NotificationRequest.find_by_report_type_and_team_id(2,params[:id])
    req.match_queue = '{3-836,3-837,12-79}'
    req.save
    
    NotificationRequest.send_periodic_report(0,0,logger)
    render :text=>'NotificationRequest.send_periodic_report(0,0,logger) was called'
  end
  
  
  
  #def periodic_report
  #  # Queue up a report
  #  
  #  begin
  #    PeriodicNotificationRequest.queue_pending_reports(2,10)
  #
  #    # collect the pending reports
  #    @report_logs, displayed_objects, team_ids, member_ids = PendingReport.collect_pending_reports
  #    #debugger
  #
  #    return if @report_logs.size == 0
  #
  #    logger.debug "Process #{@report_logs.size} reports"
  #    # get all the data needed to complete the notifications
  #    @teams = Team.find(:all, :select=>'id, title', :conditions=> { :id=>team_ids} )
  #    @recipients = Member.find(:all, :select=>'id, first_name, last_name, email', :conditions=> { :id=>member_ids} )
  #    @comments = Comment.all(
  #    :select => 'c.id, text, c.updated_at, first_name, last_name',
  #    :conditions => { 'c.id'=>displayed_objects['3'].uniq},
  #    :joins => 'as c inner join members as m on m.id = c.member_id' 
  #    )
  #    @answers = Answer.find_all_by_id(displayed_objects['2'].uniq)
  #    @bs_ideas = BsIdea.find_all_by_id(displayed_objects['11'].uniq)
  #
  #    # generat the emails for each report
  #    @report_logs.each do |r|
  #      report = r[:report]
  #      results = r[:report_results]
  #      recip = @recipients.detect{|m| m.id == report.member_id}
  #      NotificationMailer.deliver_periodic_report(recip,report,results)
  #    end    
  #  
  #  
  #  
  #    ## generate the notification data
  #    #@report_logs, displayed_objects, team_ids, member_ids = PendingReport.send_all
  #    ##debugger
  #    #if @report_logs.size == 0
  #    #  render :text=>'No activity to report'
  #    #  return
  #    #end
  #    #
  #    #
  #    ## get all the data needed to complete the notifications
  #    #@teams = Team.find(:all, :select=>'id, title', :conditions=> { :id=>team_ids} )
  #    #@recipients = Member.find(:all, :select=>'id, first_name, last_name, email', :conditions=> { :id=>member_ids} )
  #    #@comments = Comment.all(
  #    #:select => 'c.id, text, c.updated_at, first_name, last_name',
  #    #:conditions => { 'c.id'=>displayed_objects['3'].uniq},
  #    #:joins => 'as c inner join members as m on m.id = c.member_id' 
  #    #)
  #    #@answers = Answer.find_all_by_id(displayed_objects['2'].uniq)
  #    #@bs_ideas = BsIdea.find_all_by_id(displayed_objects['11'].uniq)
  #    #
  #    ## generat the emails for each report
  #    #@report_text = []
  #    #@report_logs.each do |r|
  #    #
  #    #  report = r[:report]
  #    #  results = r[:report_results]
  #    #  recip = @recipients.detect{|m| m.id == report.member_id}
  #    #  html = render_to_string :partial=>'periodic_report', :locals=>{:recip=>recip, :report=>report, :results=>results}
  #    #  NotificationMailer.deliver_periodic_report(recip,html)
  #    #
  #    #  @report_text.push html
  #    #end
  #    
  #  #rescue
  #  #  debugger
  #  end
  #      
  #end
  
end
