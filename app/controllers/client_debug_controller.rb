class ClientDebugController < ApplicationController
  def report
  end

  def ape_report
    if params[:restart] == 'true'
      @host = request.env["HTTP_HOST"]
      ClientDebugMailer.deliver_ape_restart(@member, params[:browser], @host )
      render :text=>'ok'
      
    end
  end
  
  protected
    def authorize
    end

end
