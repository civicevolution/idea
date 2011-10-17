class ChatController < ApplicationController
  layout "plan", :only => [:suggest_new_idea, :review_proposal_idea]
  skip_before_filter :authorize, :only => [ :index, :summary, :suggest_new_idea, :new_content]
  
  def jug
    Juggernaut.publish(params[:ch], params[:str])
    render :text => "str: #{params[:str]} was sent to juggernaut"
  end
  
  def send_chat_message
    Juggernaut.publish(params[:team_id], params[:msg])
    #render :text => "ok on team_id: #{params[:team_id]} with msg: #{params[:msg]}"
  end

  def chat_form
    
  end
  
end
