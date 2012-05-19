class ChatController < ApplicationController
  layout "plan", :only => [:suggest_new_idea, :review_proposal_idea]
  skip_before_filter :authorize, :only => [ :chat_form, :juggernaut_xmit ]
  
  def jug
    Juggernaut.publish(params[:ch], params[:str])
    render :text => "str: #{params[:str]} was sent to juggernaut"
  end
  
  def test_insert
    case params[:type]
    when 'com'
      model = Comment.find(params[:id])
    when 'tp'
      model = TalkingPoint.find(params[:id])
    when 'end'
      model = Endorsement.find(params[:id])
    end
    TrackingNotifications.process_event( {:event => 'after_create', :model => model} )
    render :text=>'ok'
  end
  
  def send_chat_message
    logger.debug "Publish the chat message"
    Juggernaut.publish("_auth_team_#{params[:team_id]}", {:act=>'update_chat', :name=>"#{@member.first_name} #{@member.last_name.slice(0)}",  :msg=>params[:msg]}, :except => request.headers["X-Juggernaut-Id"] )
  end

  def chat_form
    
  end

  def juggernaut_xmit
    logger.debug "Publish the juggernaut message"
    # "jug_data"=>{"act"=>"change_page_url", "url"=>"http://live.civicevolution.dev/live/23/table", "channels"=>["_auth_event_", "_auth_event__theme_2"]}
    params[:jug_data][:channels].each do |channel|
      
      logger.debug "Send msg on channel: #{channel}"
      
      if params[:jug_data][:only]
        Juggernaut.publish( channel, params[:jug_data], :only => params[:jug_data][:only]  )
      else
        Juggernaut.publish( channel, params[:jug_data] )
      end
      
      #Juggernaut.publish( channel, params[:jug_data] )
      #Juggernaut.publish( channel, params[:jug_data], :except => ['1375471368428126150','1788270420840005565']  )
      #Juggernaut.publish( channel, params[:jug_data], :only => '1429692844602455874'  )
      # Juggernaut.publish( channel, params[:jug_data], :except => request.headers["X-Juggernaut-Id"]  )
    end
    
    render :template => 'chat/ack_juggernaut_xmit.js'
  end

  
end
