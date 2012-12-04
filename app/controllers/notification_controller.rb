class NotificationController < ApplicationController
  skip_before_filter :authorize, :only => [ :settings, :follow_initiative_form, :follow_initiative_post ]
    
  def unsubscribe
    @member.update_attributes( :email_ok => false)
    render :layout=> 'plan'
  end
  
  def settings_form
    @team = Team.where(:id=>params[:team_id])

    allowed,message = InitiativeRestriction.allow_actionX({:team_id => params[:team_id]}, 'view_idea_page', @member)
    if !allowed
      if request.xhr?
        render :text => '<p> You are not allowed to access this proposal. ' + message + '</p>', :layout=> false #, :status => 409
      else
        render :template => 'idea/private_page', :layout => 'plan'
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
    @saved, notification = @notification_setting.split_n_save  
    
    ParticipantStats.find_by_member_id_and_team_id(@member.id,params[:team_id]).update_attributes(set_following: true)

    ActiveSupport::Notifications.instrument( 'tracking', :event => 'Update notification settings', :params => params.merge(:member_id => @member.id, :notification => notification))
    
    respond_to do |format|
      format.html { render :template=>'notification/update_notification_settings', :locals=>{:team_id=>params[:team_id]}, :layout=> 'plan'  }
      format.js { render :template=>'notification/update_notification_settings', :formats => [:js], :locals=>{:team_id=>params[:team_id]} }
    end
  end
  
  def follow_initiative_form
    # if they are a member look up their current state
    respond_to do |format|
      format.html { render :template=>'notification/follow_initiative', :layout=> 'plan' }
      format.js { render :template=>'notification/follow_initiative' }
    end
  end
  
  def follow_initiative_post
    @act = params[:follow].nil? ? 'remove' : 'add'
    email = @member.email.nil?	|| @member.email.length == 0 ? params[:email] : @member.email
    AdminMailer.delay.subscribe_to_follow_initiative( email, params[:_initiative_id], @act ) 
    msg = params[:follow].nil? ? 'We will unsubscribe you' : 'Thank you for subscribing to CivicEvoution updates'
    respond_to do |format|
      format.js { render 'initiative_subscribed' }
      format.html { redirect_to( home_path, :flash => { :subscribed => msg}) }
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
  
  def display_immediate
    if @member.id != 1
      respond_to do |format|
        format.html { render 'shared/private', :layout => 'plan' }
        format.js { render 'shared/private' }
      end
      return
    end
    
    log = TeamContentLog.find(params[:id])
    log.processed = false
    log.save

    @recip, @team, @report, @entry, @mcode, @host  = NotificationRequest.check_team_content_log(logger, true)
    if @team.nil?
      render :text => "No notification request for immediate report"
    elsif @entry.nil?
      render :text => 'Content was deleted'
    else
      if params[:text]
        render :template => 'notification_mailer/immediate_report.text', :layout=>'email_preview' 
      else
        render :template => 'notification_mailer/immediate_report', :layout=>'email_preview' 
      end
    end
  end

  def send_immediate
    if @member.id != 1
      respond_to do |format|
        format.html { render 'shared/private', :layout => 'plan' }
        format.js { render 'shared/private' }
      end
      return
    end
    
    log = TeamContentLog.find(params[:id])
    log.processed = false
    log.save
    NotificationRequest.check_team_content_log(logger)
    render :text=>'NotificationRequest.check_team_content_log(logger) was called'
  end
  
  def display_periodic
    if @member.id != 1
      respond_to do |format|
        format.html { render 'shared/private', :layout => 'plan' }
        format.js { render 'shared/private' }
      end
      return
    end

    req = NotificationRequest.find_by_member_id_and_report_type_and_team_id(1,4,10095)
    #req.match_queue = '{3-1227,13-76}'
    #req.match_queue = '{3-1305,3-1304,20-888,20-887}'
    #req.match_queue = '{3-1446,3-1447,3-1448,20-1818,20-1819,20-1820}'
    req.match_queue = '{20-1852,20-512}'
    req.immediate = false
    req.dow_to_run = nil
    req.hour_to_run = nil
    req.save

    #req = NotificationRequest.find_by_member_id_and_report_type_and_team_id(1,4,10048)
    #req.match_queue = '{3-734, 3-737}'
    #req.immediate = false
    #req.dow_to_run = nil
    #req.hour_to_run = nil
    #req.save
    
    @recip, @teams, @ideas, @comments, @reports, @mcode = NotificationRequest.send_periodic_report(0,0,logger, true)

    if params[:text]
      render :template => 'notification_mailer/periodic_report.text', :layout=>'email_preview' 
    else
      render :template => 'notification_mailer/periodic_report', :formats => [:html], :layout=>'email_preview' 
    end
    
    #render :text=>'NotificationRequest.send_periodic_report(0,0,logger) was called'
  end

  def send_periodic
    if @member.id != 1
      respond_to do |format|
        format.html { render 'shared/private', :layout => 'plan' }
        format.js { render 'shared/private' }
      end
      return
    end

    req = NotificationRequest.find_by_member_id_and_report_type_and_team_id(1,4,10065)
    req.match_queue = '{3-1305,3-1304,20-888,20-887}'
    req.immediate = false
    req.dow_to_run = nil
    req.hour_to_run = nil
    req.save

    #req = NotificationRequest.find_by_member_id_and_report_type_and_team_id(1,4,10048)
    #req.match_queue = '{3-734, 3-737}'
    #req.immediate = false
    #req.dow_to_run = nil
    #req.hour_to_run = nil
    #req.save
    
    NotificationRequest.send_periodic_report(0,0,logger)
    render :text=>'NotificationRequest.send_periodic_report(0,0,logger) was called'
  end
  
end
