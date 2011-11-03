class ChatController < ApplicationController
  layout "plan", :only => [:suggest_new_idea, :review_proposal_idea]
  skip_before_filter :authorize, :only => [ :index, :summary, :suggest_new_idea, :new_content]
  
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
  
end
