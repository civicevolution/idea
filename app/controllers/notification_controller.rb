class NotificationController < ApplicationController

  
  
  def settings
    @team = Team.select('id,title,initiative_id').where(:id=>params[:id])

    allowed,message = InitiativeRestriction.allow_action(@team[0].initiative_id, 'view_idea_page', @member)
    if !allowed
      if request.xhr?
        render :text => '<p> You are not allowed to access this proposal. ' + message + '</p>', :layout=> false #, :status => 409
      else
        render :template => 'idea/private_page', :layout => 'welcome'
      end
      return
    end

    @teams = (@team + @member.team_titles).map{|t| [t.title, t.id]}.uniq
    @team = @team[0]
    @notification_setting = NotificationRequest.new :member_id=>@member.id, :team_id=>@team.id, :act=>'init'
    
    render :action=>'settings', :layout=> request.xhr? ? false : 'welcome', :locals => {:xhr => request.xhr? }
  end

  def update_notification_settings
    logger.debug "update_notification_settings params: #{params.inspect}"
    @team = Team.select('id, title, initiative_id').where(:id=>params[:notification_setting][:team_id])
    allowed,message = InitiativeRestriction.allow_action(@team[0].initiative_id, 'view_idea_page', @member)
    if !allowed
      if request.xhr?
        render :text => message, :layout=> false, :status => 409
      else
        render :template => 'idea/private_page', :layout => 'welcome'
      end
      return
    end

    @notification_setting = NotificationRequest.new :member_id=>@member.id, :act=>'split_save'
    @notification_setting.attributes = params[:notification_setting]        
    @saved = @notification_setting.split_n_save  

    if request.xhr?
      render :text => @saved ? 'OK' : 'FAIL'
    else
      render :action=>'update_notification_settings', :layout=> 'welcome' 
    end
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
    
    req = NotificationRequest.find_by_report_type_and_team_id(2,10013)
    req.match_queue = '{3-854,3-854}'
    req.save
    
    NotificationRequest.send_periodic_report(0,0,logger)
    render :text=>'NotificationRequest.send_periodic_report(0,0,logger) was called'
  end

end
