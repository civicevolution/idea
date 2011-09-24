class NotificationController < ApplicationController
  skip_before_filter :authorize, :only => [ :settings ]
    
  def unsubscribe
    @member.update_attributes( :email_ok => false)
    render :layout=> 'welcome'
  end
  
  def settings_form
    @team = Team.where(:id=>params[:team_id])

    allowed,message = InitiativeRestriction.allow_actionX({:team_id => params[:team_id]}, 'view_idea_page', @member)
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

    respond_to do |format|
      format.html { render :template=>'notification/settings', :layout=> 'plan' }
      format.js { render :template=>'notification/settings' }
    end
  end

  def update_notification_settings
    logger.debug "update_notification_settings params: #{params.inspect}"

    @team = Team.select('id, title, initiative_id').where(:id=>params[:team_id])
    allowed,message = InitiativeRestriction.allow_actionX({:team_id => params[:team_id]}, 'view_idea_page', @member)
    if !allowed
      respond_to do |format|
        format.html { render 'shared/private', :layout => 'plan' }
        format.js { render 'shared/private' }
      end
      return
    end

    @notification_setting = NotificationRequest.new :member_id=>@member.id, :act=>'split_save'
    @notification_setting.attributes = params[:notification_setting]   
    @notification_setting.team_id = params[:team_id]     
    @saved = @notification_setting.split_n_save  

    respond_to do |format|
      format.html { render :template=>'notification/update_notification_settings', :locals=>{:team_id=>params[:team_id]}, :layout=> 'plan'  }
      format.js { render :template=>'notification/update_notification_settings.js', :locals=>{:team_id=>params[:team_id]} }
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
    
    req = NotificationRequest.find_by_member_id_and_report_type_and_team_id(1,2,10013)
    req.match_queue = '{3-854,12-88,12-87,12-86}'
    req.save

    req = NotificationRequest.find_by_member_id_and_report_type_and_team_id(1,2,10028)
    req.match_queue = '{3-684,3-685}'
    req.save
    
    NotificationRequest.send_periodic_report(0,0,logger)
    render :text=>'NotificationRequest.send_periodic_report(0,0,logger) was called'
  end
  
end
