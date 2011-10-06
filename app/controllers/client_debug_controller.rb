class ClientDebugController < ApplicationController
  skip_before_filter :authorize
  
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
  
  
  def report
    case
      when params.key?(:talking_point_id)
        @target = TalkingPoint.find(params[:talking_point_id])
      when params.key?(:comment_id)
        @target = Comment.find(params[:comment_id])
      when params.key?(:answer_id)
        @target = Answer.find(params[:answer_id])
    end
    @text = @target.text
    @team = @target.team
    
    @text += "..." if @text.slice!(200 .. -1)

    respond_to do |format|
      format.js {render :action=> 'report', :layout=>false}
      format.html {render :action=> 'report', :layout=>'plan'}
      format.xml  { render :xml => @comment }
    end
    
  end
  
  def post_content_report
    @report = ContentReport.new params[:content_report]
    if @member.id > 0 
      @report.member_id = @member.id
      @report.sender_name = @member.first_name + ' ' + @member.last_name
      @report.sender_email = @member.email
    end
    @saved = @report.save
    
    if @saved
      case @report.content_type
        when 'Answer'
          @target = Answer.find(@report.content_id)
        when 'Comment'
          @target = Comment.find(@report.content_id )
        when 'TalkingPoint'
          @target = TalkingPoint.find(@report.content_id )
      end

      AdminReportMailer.delay.report_content(@report, @target, request.env['HTTP_HOST'],params[:_app_name] )
    
    end
    
    @team = @target.team
    respond_to do |format|
      if @saved
        format.js { render 'report_acknowledgement' }
        format.html { render 'report_acknowledgement', :layout => 'plan' }
      else
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end

  end
  
  def request_help
    render :action => "request_help", :layout => 'plan' 
  end
  
  def request_help_post
    team_id = params[:url] && params[:url].match(/\d+$/) ? params[:url].match(/\d+$/)[0] : nil
    # create the client_details
    client_details = ClientDetails.new :ip=> request.remote_ip, :session_id=> request.session_options[:id], :member_id=> session[:member_id], 
      :team_id=> team_id, :url=> params[:url], :user_agent=> params[:user_agent], :error_log=> params[:error_log]
    @saved = client_details.save
    
    if @saved
      @help_request = HelpRequest.new params[:request_help]
      @help_request.client_details_id = client_details.id
      @saved = @help_request.save
    end
    
    if @saved
      case @help_request.category
      	when 1
      	  @help_request['type'] = 'Report a bug'
      	when 2
      	  @help_request['type'] = 'I need help to use CivicEvolution'
      	when 3
      	  @help_request['type'] = 'I need assistance with my proposal'
      	when 4
      	  @help_request['type'] = 'I need help dealing with my fellow participants'
      	when 5
      	  @help_request['type'] = 'I need technical assistance with my proposal'
      	when 6
      	  @help_request['type'] = 'I have a suggestion'
      end
      if @member.id == 0
        @member = { :first_name=>params[:request_help][:name], :email=>params[:request_help][:email]}
      end

      HelpMailer.delay.help_request_review(@member, @help_request, client_details, request.env['HTTP_HOST'], params[:_app_name])
      begin
        HelpMailer.delay.help_request_receipt(@member, @help_request, client_details ) unless @member[:email].nil?
      rescue
        @mail_error = true
      end
      
      ActiveSupport::Notifications.instrument( 'tracking', :event => 'Request help', :params => params.merge(:member_id => @member.id, :team_id => team_id ))
    end
    
    respond_to do |format|
      if @saved
        format.js { render :action => "request_help_acknowledgement", :layout => false }
        format.html { render :action => "request_help_acknowledgement", :layout => 'plan' }
        format.html { render :action => "request_help_acknowledgement", :layout => false } if request.xhr?
      else
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end
    
  end
  
end
