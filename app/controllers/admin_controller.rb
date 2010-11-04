require 'RedCloth'
module RedCloth::Formatters::HTML
  def em(opts)
    "_#{opts[:text]}_"
  end
end
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
      @recipient = Member.find_by_id( params[:recip_ids][0].to_i )
      @mcode = '~~SECRET~ACCESS~CODE~~'
      msg = render_to_string :inline=>message
      html = RedCloth.new( msg ).to_html
      
      respond_to do |format|
        format.html { render :text => html, :layout => false } if request.xhr?
        #email = AdminMailer.create_email_message(@recipient, params[:subject], msg, RedCloth.new( msg ).to_html )
        #format.html { render :text => "<pre>#{email.encoded}</pre>", :layout => false } if request.xhr?
        format.html { render :text => "Please set up admin:email for non ajax" } 
      end
      
      return
      
    elsif params[:act] == 'send'
      include_bcc = true
      Member.find_all_by_id( params[:recip_ids].map{|r| r.to_i } ).each do |@recipient|
        @mcode = MemberLookupCode.get_code(@recipient.id, {:scenario=>'admin send email'})
        msg = render_to_string :inline=>message
        AdminMailer.deliver_email_message(@recipient, params[:subject], msg, RedCloth.new( msg ).to_html, include_bcc )
        include_bcc = false
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