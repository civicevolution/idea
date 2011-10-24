class CeLiveController < ApplicationController
  layout "ce_live"
  skip_before_filter :authorize, :only => [ ]
  
  def jug
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
  
  def index
    
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
