class CallToActionController < ApplicationController

  def landing_message
    logger.debug "Show the template for #{params[:scenario]}"
    
    render :partial => params[:scenario], :layout=>'plan'
    
  end

  def load_cta_options
    
  end

  def save_to_queue
    
    if params[:scenario] == 'clear'
      ctaq = CallToActionQueue.find_by_member_id_and_team_id( params[:member_id], params[:team_id])
      ctaq.destroy() unless ctaq.nil?
      render :text=>''
    else
      ctaq = CallToActionQueue.find_by_member_id_and_team_id( params[:member_id], params[:team_id])
      if ctaq.nil?
        ctaq = CallToActionQueue.new :member_id=>params[:member_id], :team_id=>params[:team_id], :scenario=>params[:scenario], :sent=>false    
      else
        ctaq.scenario = params[:scenario]
        ctaq.sent = false
      end
      ctaq.save
      render :text=>ctaq.scenario
    end
  end

end
