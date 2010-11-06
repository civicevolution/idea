class ClientDebugController < ApplicationController
  def report
  end

  def ape_report
    if params[:failure]
      @host = request.env["HTTP_HOST"]
      ClientDebugMailer.deliver_ape_failure(@member, params[:failure], params[:browser], @host )
      render :text=>'ok'
      
    end
  end
  
  protected
    def authorize
    end

end
