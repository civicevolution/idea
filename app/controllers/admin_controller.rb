require 'RedCloth'
class AdminController < ApplicationController
  
  before_filter :get_admin_privileges

  def index
    
  end

  def change_member_id
    
    session[:member_id] = params[:id]
    flash.now[:notice] = "Your session has been changed to member id: #{params[:id]}"
    render :action=>'index'
    
  end
  
  def members
    @members = Member.gen_report(params[:_initiative_id])
  end

  def teams
    @teams = Team.gen_report(params[:_initiative_id])
  end

  def ideas
    @ideas = ProposalIdea.all()
  end

  def team_workspace
    
  end
  
  def team_members
    
  end
  
  def email
    message = params[:message]
    @team = Team.find(params[:team_id])
    @host = request.env["HTTP_HOST"]
    
    if params[:act] == 'preview'
      @recipient = Member.find_by_id( params[:recip_ids].split(',') )
      @mcode = MemberLookupCode.get_code(@recipient.id)
      msg = render_to_string :inline=>message
      html = RedCloth.new( msg ).to_html
      
      respond_to do |format|
        format.html { render :text => html, :layout => false } if request.xhr?
        format.html { render :text => "Please set up admin:email for non ajax" } 
      end
      
      return
      
    elsif params[:act] == 'send'

      Member.find_all_by_id( params[:recip_ids].split(',') ).each do |@recipient|
        @mcode = MemberLookupCode.get_code(@recipient.id)
        msg = render_to_string :inline=>message
        AdminMailer.deliver_email_message(@recipient, msg, RedCloth.new( msg ).to_html )
      end
      
      respond_to do |format|
        format.html { render :text => "sent ok", :layout => false } if request.xhr?
        format.html { render :action => "item_history" } 
      end
      
    else
      
    end
    
    
  end
  
  def create_admins
    if params[:act] == 'add_new_privilege'
      ap = AdminPrivilege.new :admin_group_id=>params[:id], :title=> params[:title].gsub(/ /,'')
      ap.save
      
      params[:s] = 'list_group_privileges'
    end

    
  end


  protected
  
    def get_admin_privileges
      logger.debug "get_admin_privileges"
      @privileges = AdminPrivilege.read_privileges( session[:member_id],params[:_initiative_id])
      
      if @privileges.size == 0
        render :action => 'not_recognized_admin'
        return
      end
      
      # check the action against the privileges
      if request.parameters[:action] != 'index' && !@privileges.include?( request.parameters[:action] )
        logger.debug "user doesn't have privileges for #{request.parameters[:action]}"
        render :action => 'not_authorized'
        return
      end
      
      logger.debug "get_admin_privileges @privileges: #{@privileges}"
      @initiative = Initiative.find(params[:_initiative_id])
      
    end

end