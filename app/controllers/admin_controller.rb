#require 'RedCloth'
#module RedCloth::Formatters::HTML
#  def em(opts)
#    "_#{opts[:text]}_"
#  end
#end
require 'bluecloth'
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
    #@team = Team.find_by_id(params[:team_id])
    @host = request.env["HTTP_HOST"]
    @email_recipients = nil

    if params[:act] == 'fetch_recipients'
      logger.debug "Load the recipients #{params[:recipient_source]}"
      @email_recipients = CallToActionEmail.get_recipients_by_query(params[:recipient_source])
      logger.debug "@email_recipients.size: #{@email_recipients.size}"
      respond_to do |format|
        format.html { render :partial => 'email_recipients' } if request.xhr?
        #email = AdminMailer.create_email_message(@recipient, params[:subject], msg, BlueCloth.new( msg ).to_html )
        #format.html { render :text => "<pre>#{email.encoded}</pre>", :layout => false } if request.xhr?
        format.html { render :text => "Please set up admin:email for non ajax" } 
      end
      return

    elsif params[:act] == 'fetch_scenario' 
      logger.debug "Load the scenario #{params[:scenario]}"
      @cta_email = CallToActionEmail.get_scenario(params[:scenario])
      @scenarios = CallToActionEmail.get_scenarios()
      @versions = CallToActionEmail.get_versions(@cta_email.scenario)
      
      respond_to do |format|
        format.html { render :partial => 'email_compose' } if request.xhr?
        #email = AdminMailer.create_email_message(@recipient, params[:subject], msg, BlueCloth.new( msg ).to_html )
        #format.html { render :text => "<pre>#{email.encoded}</pre>", :layout => false } if request.xhr?
        format.html { render :text => "Please set up admin:email for non ajax" } 
      end
      return
    elsif params[:act] == 'fetch_version'
      logger.debug "Load the version #{params[:scenario]}-#{params[:version]}"
      @cta_email = CallToActionEmail.get_version(params[:scenario],params[:version])
      @scenarios = CallToActionEmail.get_scenarios()
      @versions = CallToActionEmail.get_versions(@cta_email.scenario)
      
      respond_to do |format|
        format.html { render :partial => 'email_compose' } if request.xhr?
        #email = AdminMailer.create_email_message(@recipient, params[:subject], msg, BlueCloth.new( msg ).to_html )
        #format.html { render :text => "<pre>#{email.encoded}</pre>", :layout => false } if request.xhr?
        format.html { render :text => "Please set up admin:email for non ajax" } 
      end
      return
       
    elsif params[:act] == 'preview'
      mem_id, team_id = params[:recip_ids][0].split('-')
      @recipient = Member.find_by_id( mem_id.to_i )
      @team = Team.find_by_id(team_id.to_i)
      @team = Team.find_by_id(10022) if @team.nil? && mem_id.to_i == 1
      @mcode = '~~SECRET~ACCESS~CODE~~'
      msg = render_to_string :inline=>message
      html = "<h3>#{params[:subject]}</h3>"
      html += BlueCloth.new( msg ).to_html
      
      respond_to do |format|
        format.html { render :text => html, :layout => false } if request.xhr?
        #email = AdminMailer.create_email_message(@recipient, params[:subject], msg, BlueCloth.new( msg ).to_html )
        #format.html { render :text => "<pre>#{email.encoded}</pre>", :layout => false } if request.xhr?
        format.html { render :text => "Please set up admin:email for non ajax" } 
      end
      
      return
      
    elsif params[:act] == 'send'
      text = ''
      if params[:save_scenario] == 'true'
        logger.debug "Save this version"
        cta_email = CallToActionEmail.find_by_scenario_and_version(params[:new_scenario].strip, params[:new_version])
        if cta_email.nil?
          cta_email = CallToActionEmail.new(
            :scenario=>params[:new_scenario], :version=>params[:new_version], :subject=>params[:subject], :message=>params[:message]
          )
          cta_email.save
        else
          cta_email.update_attributes(
            :scenario=>params[:new_scenario], :version=>params[:new_version], :subject=>params[:subject], :message=>params[:message]
          )          
        end
        
        params[:scenario] = params[:new_scenario]
        params[:version] = params[:new_version]
        text += "Email was saved as #{params[:scenario]}, ver: #{params[:version]}"
      end
      if params[:send] == 'true'
        logger.debug "send this version"
        include_bcc = true
        #Member.find_all_by_id( params[:recip_ids].map{|r| r.to_i } ).each do |@recipient|
        params[:recip_ids].each do |recip_id|
          mem_id, team_id = recip_id.split('-')
          @recipient = Member.find_by_id( mem_id.to_i )
          @team = Team.find_by_id(team_id.to_i)
          @team = Team.find_by_id(10022) if @team.nil? && mem_id.to_i == 1
          
          @mcode,mcode_id = MemberLookupCode.get_code_and_id(@recipient.id, {:scenario=>params[:scenario]})
          msg = render_to_string :inline=>message
          AdminMailer.deliver_email_message(@recipient, params[:subject], msg, BlueCloth.new( msg ).to_html, include_bcc )
          include_bcc = false
          # record details on each email that is sent
          ctaes = CallToActionEmailsSent.new(
            :member_id=> @recipient.id, 
            :member_lookup_code_id => mcode_id,
            :scenario=> params[:scenario],
            :version=> params[:version],
            :team_id=> params[:team_id]
          )
          ctaes.save
          #update as most recent email
          cta_email = CallToActionEmail.find(1)
          cta_email.update_attributes(
            :scenario=>params[:scenario], :version=>params[:version], :subject=>params[:subject], :message=>params[:message]
          )
          #cta_email.save
        end
        text += "\nEmail was sent ok"
      end

      respond_to do |format|
        format.html { render :text => text, :layout => false } if request.xhr?
        format.html { render :action => "item_history" } 
      end
      
    else
      logger.debug "default - show most recent email"
      # load the most recent email, always stored as #1
      @cta_email = CallToActionEmail.get_most_recent()
      @scenarios = CallToActionEmail.get_scenarios()
      @versions = CallToActionEmail.get_versions(@cta_email.scenario)
      
    end
  end
  
  def create_admins
    if params[:act] == 'add_new_privilege'
      ap = AdminPrivilege.new :admin_group_id=>params[:id], :title=> params[:title].gsub(/ /,'')
      ap.save
      
      params[:s] = 'list_group_privileges'
      
    elsif params[:act] == 'add_new_group'
      a = Admin.new :member_id=>params[:member_id], :admin_group_id=>params[:admin_group_id], :initiative_id=>params[:initiative_id]
      a.save  
      params[:s] = 'list_groups'
      
    elsif params[:act] == 'remove_admin_group'
      a = Admin.find_by_admin_group_id_and_initiative_id_and_member_id params[:admin_group_id], params[:initiative_id], params[:member_id]
      a.destroy unless a.nil?
      params[:s] = 'list_groups'
      
    end

    
  end
  
  def content_stats
    @com_stats = Comment.find_by_sql(%q|SELECT count(id) AS cnt, COUNT(DISTINCT member_id) AS commentors, DATE_TRUNC('day', created_at + interval '19 hours') AS day, TO_CHAR(created_at + interval '19 hours', 'Dy Mon DD, YYYY') AS cal_day
    FROM comments
    WHERE team_id IN (SELECT id FROM teams WHERE initiative_id IN (1,2) )
    GROUP BY day, cal_day ORDER BY day ASC|)

    @idea_stats = BsIdea.find_by_sql(%q|SELECT count(id) AS cnt, COUNT(DISTINCT member_id) AS members, DATE_TRUNC('day', created_at + interval '19 hours') AS day, TO_CHAR(created_at + interval '19 hours', 'Dy Mon DD, YYYY') AS cal_day
    FROM bs_ideas
    WHERE team_id IN (SELECT id FROM teams WHERE initiative_id IN (1,2) )
    GROUP BY day, cal_day ORDER BY day ASC|);

    @ans_stats = Answer.find_by_sql(%q|SELECT count(id) AS cnt, COUNT(DISTINCT member_id) AS members, DATE_TRUNC('day', created_at + interval '19 hours') AS day, TO_CHAR(created_at + interval '19 hours', 'Dy Mon DD, YYYY') AS cal_day
    FROM answers
    WHERE team_id IN (SELECT id FROM teams WHERE initiative_id IN (1,2) )
    GROUP BY day, cal_day ORDER BY day ASC|);
    
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