class CeLiveController < ApplicationController
  layout "ce_live"
  skip_before_filter :authorize, :only => [ ]
  
  def ltp_to_jug
    ltp = LiveTalkingPoint.find(params[:id])
    Juggernaut.publish(params[:ch], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
    render :text => "On juggernaut on channel; #{params[:ch]}, sent LiveTalkingPoint: #{ltp.inspect}", :content_type => 'text/plain'
  end
  
  def send_chat_message
    logger.debug "Publish the chat message"
    Juggernaut.publish(params[:team_id], {:act=>'update_chat', :name=>"#{@member.first_name} #{@member.last_name.slice(0)}",  :msg=>params[:msg]}, :except => request.headers["X-Juggernaut-Id"] )
  end

  def chat_form
    
  end
  
  def theme
    
  end
  
  def group
    
  end
  
  def get_tp_test_ids
    group_range = params[:group_range].split('..').map{|d| Integer(d)}
    ltp_ids = LiveTalkingPoint.select('id').where(:live_session_id => params[:live_session_id], :group_id => group_range[0]..group_range[1] ).collect{|ltp| ltp.id}.shuffle
    render( :template => 'ce_live/get_tp_test_ids.js', :locals =>{:live_talking_point_ids => ltp_ids})
  end
  
  def post_talking_point_from_group
    
    # I want to use session to determine 
    # live_session_id
    # group_id
    # channel
    
    ltp = LiveTalkingPoint.new live_session_id: params[:sid], group_id: params[:gid], text: params[:text]
    ltp.id = 1234
    
    Juggernaut.publish(params[:channel], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
    render( :template => 'ce_live/post_talking_point_from_group.js', :locals =>{:live_talking_point => ltp})
  end
  
  def get_templates
    # Set up all of the data I need for the templates to run
    # Build the templates in the templates.js template which will insert the HTML in script blocks text/html to hide them from browser processing
    # Add the directives to templates.js
    # Compile the templates when this loads into the browser


    old_ts = Time.local(2020,1,1)
    newer_ts = Time.local(2025,1,1)

    @live_talking_point = LiveTalkingPoint.new(:created_at => old_ts, :updated_at => newer_ts)

    # what do I need to know for the comment template?
    @live_talking_point.text = ''
    @live_talking_point.id = 0

    # the templates are built in get_templates.js
    render :template => 'ce_live/get_templates.html', :layout => false #, :content_type => 'application/javascript'
    
  end
  
  def session_test
    ltps = LiveTalkingPoint.where(:live_session_id => params[:sid], :group_id => params[:gid] )
    
    while ltps.size > 0
      ltp = ltps.sample
      ltps.delete ltp
      Juggernaut.publish(params[:ch], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
      sleep(1.seconds)
    end
    
    render :text => 'live talking points have been sent'
    
  end
  
end
