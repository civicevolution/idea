class CallToActionController < ApplicationController

  def landing_message
    logger.debug "Show the template for #{params[:scenario]}"
    
    render :partial => params[:scenario], :layout=>'welcome'
    
  end

end
