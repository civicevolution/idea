require 'recaptcha'
class WelcomeController < ApplicationController
  include ReCaptcha::AppHelper
  
  def index
    logger.warn "Welcome controller index APP_NAME: #{APP_NAME}, request.subdomains.first: #{request.subdomains.first}"
    # if I have a current session, get my teams and insert them into the page instead of the signin form
    # use a partial template and layout to create initiative specific page details
    
    # get current list of teams for this initiative    
    #@init_teams = Team.find_all_by_initiative_id(params[:_initiative_id])
    @init_teams = Team.teams_with_stats(params[:_initiative_id])
    @teams_launched = @init_teams.find_all {|t| t.launched == true }
    @team_ideas = @init_teams.find_all {|t| t.launched == false }
    
    # get ids of most active teams
    
    # get ids of completed teams

    # get statistics for initiative teams - combine that with the teams request, including most active and completed
    
  end
  
  def home
    logger.debug "Show the CE home page"
    render :action=>'home', :layout=>false
  end

  def signin
    logger.debug "signin #{params.inspect}"
    if request.post?
      @member = Member.authenticate(params[:email], params[:password])
     
      if request.xhr?
        if @member
          session[:member_id] = @member.id
          #@mem_teams = TeamRegistration.find(:all,
          #  :select => 't.id, t.title, t.launched',  
          #  :conditions => ['member_id = ?', @member.id],
          #  :joins => 'as tr inner join teams t on tr.team_id = t.id' 
          #)

          if params[:stay_signed_in]
           request.session_options = request.session_options.dup
           request.session_options[:expire_after]= 30.days
           request.session_options.freeze
          end
          if flash[:pre_authorize_uri]
            render :text => "__REDIRECT__=#{flash[:pre_authorize_uri]}"
          else
            #render :partial => "teams_list"
            render :partial => "member_info"
          end
          
        else
          # return error
          render :text=> 'Invalid email or password', :status=>409
        end
      else
        
        if @member
          session[:member_id] = @member.id
          uri = session[:original_uri]
          session[:original_uri] = nil
          #team_id = TeamRegistration.find_by_member_id(@member.id).team_id
          #team_id = 10005
          #if team_id
          #  redirect_to '/team?id=' + team_id.to_s
          #else
          #  #redirect_to 'index.html'
          #  redirect_to :controller=> 'welcome', :action => "index"
          #end          
          redirect_to :controller=> 'welcome', :action => "index"
        else
          flash.now[:notice] = "Invalid email/password combination"
          render :controller=>'welcome', :action=>'index'
        end
      end
    end
    #debugger
  end
  
  def request_new_access_code
  end
  
  def send_new_access_code
    @member = Member.find_by_email(params[:email].downcase)
    if @member.nil?
      render :text=> "Sorry, the email you entered: #{params[:email]} is not in our records.", :status=> 409
      return
    else
      # create and store a code for the member
      mcode = MemberLookupCode.get_code(@member.id)
      
      logger.debug "generate an email to #{@member.email} with code: #{mcode}"
      # generate an email to the member      
      MemberMailer.deliver_new_access_code(@member, mcode, flash[:pre_request_access_code_uri], request.env["HTTP_HOST"]) 
      @email = @member.email
      @member = nil
    end
  end
  
  def reset_password
    member = Member.find_by_email(params[:email].downcase)
    if member.nil?
      render :text=> "Sorry, the email you entered: #{params[:email]} is not in our records.", :status=> 409
      return
    else
      # create and store a code for the member
      mcode = MemberLookupCode.get_code(member.id)
      logger.debug "generate an email to #{member.email} with code: #{mcode}"
      # generate an email to the member
      
      email = MemberMailer.deliver_reset_password(member,mcode, request.env["HTTP_HOST"]) 
      render :text => 'ok'
    end
  end
  
  def password_reset
  end

  def password_reset_complete
    # now update the password
    begin
      if params[:password] != params[:password_repeat]
        flash[:notice] = 'The password must match the password repeat.'
        redirect_to :action => 'password_reset', :id=>params[:code]
        return
      end
      if @member.nil?
        render :template=> 'welcome/password_reset_bad_code', :layout=> 'welcome', :status=> 409
      else
        # change the password
        @member.password = params[:password]
        @member.save
      end
    rescue
      render :template=> 'welcome/password_reset_bad_code', :layout=> 'welcome', :status=> 409
    end
  end
  
  def join_our_community
    respond_to do |format|
      format.html { render :action => "join_our_community", :layout => false } if request.xhr?  
      format.html { render :action => "join_our_community" }
    end
  end
  
  def register
    logger.debug "register #{params.inspect}"
    @member = Member.new(params[:member])
    @member.pic_id = 0
    @member.init_id = params[:_initiative_id]
    @member.ip = request.remote_ip
    @member.email = @member.email.strip.downcase
    
    
    restrictions_test,message = InitiativeRestriction.allow_action(params[:_initiative_id], 'join_initiative', @member)
    #logger.debug "Welcome::register restrictons test result #{restrictions_test} with message: #{message}"
    
    if !restrictions_test
      logger.warn "failed restrictons test with message: #{message}"
      @saved = false
      @member.errors.add(:join, message)
    else
    
      begin
        Member.transaction do        
          logger.debug "try to save the member and the InitiativeMember record"
          memSave = @member.save  
          #logger.debug "memSave; #{memSave}"        
    
  #        # update the member id
  #        @im.member_id = @member.id
          @im = InitiativeMembers.new :initiative_id =>params[:_initiative_id], :member_id=>@member.id, :accept_tos=> params[:accept_tos], :member_category=> params[:member_category]
          logger.debug "@im: #{@im.inspect}"

          if memSave 
            imSave = @im.save
          else
            imSave = @im.valid?
          end
    
          if !memSave || !imSave
            @saved = false
            raise ActiveRecord::Rollback
          else
            @saved = true
          end
        end  # end of transaction
      rescue ActiveRecord::Rollback
        #don't need to do anything
      end # of begin block 

    end
    
    
    if @saved
      mcode = MemberLookupCode.get_code(@member.id)
      MemberMailer.deliver_confirm_registration(@member,mcode, request.env["HTTP_HOST"], params[:_app_name])
      session[:member_id] = @member.id
    end

    respond_to do |format|
      if @saved
        format.html { render :action => "acknowledge_registration", :layout => false } if request.xhr?  
      else
        @im.errors.each() {|attr, msg| @member.errors.add(attr, msg)} unless @im.nil?
        @member.errors.add(:join, "correct the problems indicated above.") if !@member.errors.nil? && @member.errors.size() > 0
        
        format.json { render :text => [@member.errors].to_json, :status => 409 }
      end
    end
  end

  def confirm_registration
  end
  
  def request_confirmation_email
    if params[:email]
      @member = Member.find_by_email(params[:email].downcase)
    #else 
    #  @member = Member.find(session[:member_id])
    end
    #@mem_teams = []
    # send a new confirmation email
    mcode = MemberLookupCode.get_code(@member.id)
    MemberMailer.deliver_confirm_registration(@member,mcode, request.env["HTTP_HOST"],params[:_app_name])
    render :action => "request_confirmation_email", :layout => false if request.xhr?  
  end
  
  def confirm_reg_captcha
    if @member.nil?
      render :text=>'no member found', :status=>409
      return
    else
      logger.debug "confirm_reg_captcha for id: #{@member.id}"
      if validate_recap(params, @member.errors)
        @member.confirmed = true
        @member.save
        session[:member_id] = @member.id
        render :text=>'ok'
      else
        render :text=>'fail', :status=>409
      end
    end
  end
  
  def broadcast_email_opt_in
    logger.debug "broadcast_email_opt_in #{params.inspect}"
    ges = GeneralEmailSettings.find_by_member_id(session[:member_id])
    ges = GeneralEmailSettings.new( :member_id=>session[:member_id] ) if ges.nil?
    ges.accept_broadcast_messages = params[:broadcast]
    if ges.save
      render :text=>"broadcast=#{params[:broadcast]}"
    else
      render :text=>'failed', :status=>409
    end
  end
  
  
  def signout
    session[:member_id] = nil
    flash[:notice] = "Signed out"
    redirect_to :controller=> 'welcome', :action => "index"
  end
  
  def terms_of_service

    respond_to do |format|
      format.html { render :action => "terms_of_service", :layout => false } if request.xhr?  
      format.html { render :action => "terms_of_service" }
    end
        
    
  end

  def upload_member_photo
    logger.debug "save_photo"
    #member = Member.find(session[:member_id])
    logger.debug "save_photo member_id: #{@member.id}"
    
    @member.photo = params[:photo]
    @member.save
    
    logger.debug "url: #{@member.photo.url('36')}"
    render :text => @member.photo.url('36')
    #respond_to do |format|
    #  format.json { render :text => ["url = '#{ member.photo.url('36')}'"].to_json }
    #end
      
  end 
  
  def request_help
    logger.debug "request_help #{params.inspect}"
    
    # do I need to store the idea, or just forward it?
    # might as well save them in one place and forward them

    team_id = params[:url] && params[:url].match(/\d+$/) ? params[:url].match(/\d+$/)[0] : nil
    # create the client_details
    client_details = ClientDetails.new :ip=> request.remote_ip, :session_id=> request.session_options[:id], :member_id=> session[:member_id], :team_id=> team_id, :url=> params[:url], :user_agent=> params[:user_agent], :error_log=> params[:error_log]
    @saved = client_details.save
    
    if @saved
      help_request = HelpRequest.new :client_details_id=> client_details.id, :name=>params[:name], :email=> params[:email], :category=> params[:category], :message=> params[:message]
      @saved = help_request.save
    end
    
    if @saved
      #member = Member.find(session[:member_id])
      HelpMailer.deliver_help_request_receipt(@member, help_request, client_details )
      HelpMailer.deliver_help_request_review(@member, help_request, client_details)
    end
    
    respond_to do |format|
      if @saved
        format.html { render :action => "acknowledge_request_help", :layout => false } if request.xhr?
      else
        format.json { render :text => [@proposal_idea.errors].to_json, :status => 409 }
      end
    end
    
  end
     
  def tabs
    
  end

  def reserve_member_code
    member = Member.find_by_email params[:email]
    if member.nil?
      member = Member.new :email=> params[:email], :first_name=> 'Place', :last_name=> 'Holder', :pic_id=>0, :init_id=>0, :hashed_pwd=>'*'
      member.save
    end
    render :text => [{:id=>member.id, :ape_code=> member.ape_code}].to_json
  end
    
protected
  def authorize
  end  

end
