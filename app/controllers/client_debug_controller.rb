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
  
  def load_report
   clt = ClientLoadTime.new :user_agent=>request.env["HTTP_USER_AGENT"], :ip=> request.remote_ip, :session_id=> request.session_options[:id], 
    :member_id=> session[:member_id], :team_id=>params[:team_id], :height=>params[:height], :width=>params[:width]
    clt.page_load = params[:page_loaded].to_i - params[:start].to_i
    clt.all_init = params[:all_init].to_i - params[:start].to_i
    clt.ape_load = params[:load_ape].to_i > 0 ? params[:load_ape].to_i - params[:start].to_i : 0
    clt.save
    render :text=>'ok'
  end
  
  protected
    def authorize
    end

end
