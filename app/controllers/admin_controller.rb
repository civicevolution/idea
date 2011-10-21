require 'bluecloth'
class AdminController < ApplicationController
  layout "plan"
  append_before_filter :get_admin_privileges

  def index
    @initiative = Initiative.find(params[:_initiative_id])
    
  end

  def change_member_id
    
    session[:member_id] = params[:id]
    flash.now[:notice] = "Your session has been changed to member id: #{params[:id]}"
    render :action=>'index'
    
  end
  
  
  def recent_content
    @start_days = params[:start_days].nil? ? 2 : params[:start_days].to_i
    @end_days = params[:end_days].nil? ? 0 : params[:end_days].to_i
    #logger.debug "recent content start: #{@start_days} till #{@end_days}"
    @items = TeamContentLog.all(
      :select=>%q|m.id AS member_id, first_name, last_name, email, t.id AS team_id, t.initiative_id, t.launched, t.title, tcl.created_at,
        (SELECT CASE WHEN tcl.o_type = 2 THEN 'ANS' WHEN tcl.o_type=3 THEN 'COM' WHEN tcl.o_type=13 THEN 'TP' END) AS type,
        (SELECT CASE WHEN tcl.o_type = 2 THEN (SELECT text FROM answers where id = tcl.o_id) WHEN tcl.o_type=3 THEN (SELECT text FROM comments where id = tcl.o_id) WHEN tcl.o_type=13 THEN (SELECT text FROM talking_points where id = tcl.o_id) END) AS content|,
      :joins=>'AS tcl INNER JOIN members AS m ON tcl.member_id = m.id INNER JOIN teams AS t ON tcl.team_id = t.id',
      :conditions=>[%q|tcl.created_at BETWEEN (now() AT time zone 'UTC') - INTERVAL '? days' AND (now() AT time zone 'UTC') - INTERVAL '? days' AND t.initiative_id IN (1,2)|,@start_days, @end_days],
      :order=>'tcl.created_at DESC'
    )

    if request.xhr?
      render :action=>'recent_content', :layout=>false
    else
      render :action=>'recent_content'
    end
  end
  
  def load_times
    @start_days = params[:start_days].nil? ? 2 : params[:start_days].to_i
    @end_days = params[:end_days].nil? ? 0 : params[:end_days].to_i

    @items = ClientLoadTime.all(
      :select=>%q|m.id AS member_id, first_name, last_name, email, t.id AS team_id, t.initiative_id, t.title, page_load, ape_load, all_init, 
        height, width, clt.created_at, user_agent, clt.ip|,
      :joins=>'AS clt INNER JOIN members AS m ON clt.member_id = m.id INNER JOIN teams AS t ON clt.team_id = t.id',
      :conditions=>[%q|clt.created_at BETWEEN (now() AT time zone 'UTC') - INTERVAL '? days' AND (now() AT time zone 'UTC') - INTERVAL '? days' AND t.initiative_id IN (1,2)|,
        @start_days, @end_days],
      :order=>'clt.created_at DESC'
    )

    if request.xhr?
      render :action=>'load_times', :layout=>false
    else
      render :action=>'load_times'
    end
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
    @email_recipients = nil

    if params[:act] == 'fetch_recipients'
      logger.debug "Load the recipients #{params[:recipient_source]}"
      @email_recipients = CallToActionEmail.get_recipients_by_query(params[:recipient_source], params[:search])
      @email_recipients.concat(
        Member.all(:select=>"first_name, last_name, email, id AS mem_id, #{@email_recipients[0].team_id} AS team_id", :conditions=>'id in (1,119)')
      ) unless params[:recipient_source] == 'team' || @email_recipients.size == 0
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
      begin
        if message.match(/@team/)
          @team = Team.find_by_id(team_id.to_i)
          @team = Team.first() if @team.nil? && (mem_id.to_i == 1 || mem_id.to_i == 119)
        end
        if message.match(/@init_data/)
          @init_data = [
            {},
            {:sponsor=>'Executive Management Team'},
            {:sponsor=>'Alliance Governance Group'}        
          ]
        end
        if message.match(/@mcode/)
          @mcode = '~~SECRET~ACCESS~CODE~~'
        end
        @init_id = params[:recipient_source] == 'join a team' ? team_id : (@team.nil? ? nil : @team.initiative_id)
        @host = @init_id.nil? ? request.env['HTTP_HOST'] : Initiative.first(:select=>'domain',:conditions=>"id = #{@init_id}").domain
        @host.sub!(/\w+$/,'dev') if Rails.env.development?
        if message.match(/@proposals/)
          @proposals = []
          Team.select("t.id,title").joins("AS t JOIN team_registrations AS tr ON tr.team_id = t.id").where("t.id > 10017 AND tr.member_id = ?", @recipient.id).each do |idea|
            mcode = '~~SECRET~ACCESS~CODE~~'
            @proposals.push %Q|- [#{idea.title}](http://#{@host}/idea/#{idea.id}?_mlc=#{mcode})\n\n|
          end
          @proposals = @proposals.join('')
        end
        
      rescue 
      end
      
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
        #logger.debug "send this version"
        #Member.find_all_by_id( params[:recip_ids].map{|r| r.to_i } ).each do |@recipient|
        params[:recip_ids].each do |recip_id|
          mem_id, team_id = recip_id.split('-')
          @recipient = Member.find_by_id( mem_id.to_i )
          begin
            if message.match(/@team/)
              @team = Team.find_by_id(team_id.to_i)
              @team = Team.first() if @team.nil? && (mem_id.to_i == 1 || mem_id.to_i == 119)
            end
            if message.match(/@init_data/)
              @init_data = [
                {},
                {:sponsor=>'Executive Management Team'},
                {:sponsor=>'Alliance Governance Group'}        
              ]
            end
            # mcode is always needed for unsubscribe built into the template
            @mcode,mcode_id = MemberLookupCode.get_code_and_id(@recipient.id, {:scenario=>params[:scenario]})

            # adjust host first subdomain based on init_id of the team or the team_id if join a team
            @init_id = params[:recipient_source] == 'join a team' ? team_id : (@team.nil? ? nil : @team.initiative_id)
            
            @host = @init_id.nil? ? request.env['HTTP_HOST'] : Initiative.first(:select=>'domain',:conditions=>"id = #{@init_id}").domain
            @host.sub!(/\w+$/,'dev') if Rails.env.development?
            if message.match(/@proposals/)
              @proposals = []
              Team.select("t.id,title").joins("AS t JOIN team_registrations AS tr ON tr.team_id = t.id").where("t.id > 10017 AND tr.member_id = ?", @recipient.id).each do |idea|
                mcode,mcode_id = MemberLookupCode.get_code_and_id(@recipient.id, {:scenario=>'List all my teams'})
                @proposals.push %Q|- [#{idea.title}](http://#{@host}/idea/#{idea.id}?_mlc=#{mcode})\n\n|
              end
              @proposals = @proposals.join('')
            end
            
          rescue
          end
          
          msg = render_to_string :inline=>message

          #AdminMailer.delay(:run_at => 5.minutes.from_now).email_message(@recipient, params[:subject], msg, BlueCloth.new( msg ).to_html )

          if @recipient.email_ok
            AdminMailer.delay.email_message(@recipient, params[:subject], msg, BlueCloth.new( msg ).to_html, @host, @mcode )
            logger.info "Sent email via delayed_job to #{@recipient.first_name} #{@recipient.last_name} <#{@recipient.email}>"
          else
            logger.info "NO EMAIL SENT - unsubscribed - for #{@recipient.first_name} #{@recipient.last_name} <#{@recipient.email}>"
          end
          #set queue sent = true
          ctaq = CallToActionQueue.find_by_member_id_and_team_id( mem_id, team_id )
          ctaq.destroy unless ctaq.nil?
        
          if mcode_id
            # record details on each email that is sent
            ctaes = CallToActionEmailsSent.new(
              :member_id=> @recipient.id, 
              :member_lookup_code_id => mcode_id,
              :scenario=> params[:scenario],
              :version=> params[:version],
              :team_id=> team_id
            )
            ctaes.save
          end
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
    case params[:act]
      when 'add_new_privilege'
        ap = AdminPrivilege.new :admin_group_id=>params[:id], :title=> params[:title].gsub(/ /,'')
        ap.save
      
        params[:s] = 'list_group_privileges'
      
      when 'add_new_group'
        a = Admin.new :member_id=>params[:member_id], :admin_group_id=>params[:admin_group_id], :initiative_id=>params[:initiative_id]
        a.save  
        params[:s] = 'list_groups'
      
      when 'remove_admin_group_privilege'
        ap = AdminPrivilege.find_by_admin_group_id_and_title(params[:admin_group_id],params[:privilege])
        ap.destroy
        params[:s] = 'list_group_privileges'
      when 'remove_admin_group'
        a = Admin.find_by_admin_group_id_and_initiative_id_and_member_id params[:admin_group_id], params[:initiative_id], params[:member_id]
        a.destroy unless a.nil?
        params[:s] = 'list_groups'
      
    end

    
  end
  
  def content_stats
    @com_stats = Comment.find_by_sql(%q|SELECT count(id) AS cnt, COUNT(DISTINCT member_id) AS commentors, DATE_TRUNC('day', created_at + interval '19 hours') AS day, TO_CHAR(created_at + interval '19 hours', 'Dy Mon DD, YYYY') AS cal_day
    FROM comments
    WHERE team_id IN (SELECT id FROM teams WHERE initiative_id IN (1,2) ) AND created_at > (now() AT time zone 'UTC') - INTERVAL '30 days'
    GROUP BY day, cal_day ORDER BY day ASC|)

    @talking_point_stats = TalkingPoint.find_by_sql(%q|SELECT count(id) AS cnt, COUNT(DISTINCT member_id) AS members, DATE_TRUNC('day', created_at + interval '19 hours') AS day, TO_CHAR(created_at + interval '19 hours', 'Dy Mon DD, YYYY') AS cal_day
    FROM talking_points
    WHERE question_id IN (SELECT id FROM questions WHERE team_id IN (SELECT id FROM teams WHERE initiative_id IN (1,2) )) AND created_at > (now() AT time zone 'UTC') - INTERVAL '30 days'
    GROUP BY day, cal_day ORDER BY day ASC|);

    @ans_stats = Answer.find_by_sql(%q|SELECT count(id) AS cnt, COUNT(DISTINCT member_id) AS members, DATE_TRUNC('day', created_at + interval '19 hours') AS day, TO_CHAR(created_at + interval '19 hours', 'Dy Mon DD, YYYY') AS cal_day
    FROM answers
    WHERE team_id IN (SELECT id FROM teams WHERE initiative_id IN (1,2) ) AND created_at > (now() AT time zone 'UTC') - INTERVAL '30 days'
    GROUP BY day, cal_day ORDER BY day ASC|);
    
  end

  def call_to_action_reports
    logger.debug "Get data for call_to_action_reports"
    @cta_records = CallToActionEmailsSent.get_all()
  end

  def auto_signin_log
    logger.debug "Get data for call_to_action_reports"
    @signin_records = MemberLookupCodeLog.get_all()
  end
  
  def team_stats
    @team_stats = Team.includes(:proposal_stats).where(:initiative_id => 1..2).order('initiative_id DESC, title ASC')
  end    
  
  def team_participant_stats
    @team_participant_stats = Team.includes(:participant_stats, {:participant_stats => :member}).find(params[:team_id]).participant_stats
    render( :template => 'admin/team_participant_stats', :locals => {:standalone => true})
  end
  
  def participant_stats 
    
    if @privileges.include? 'set_cta'
      @set_cta = true
    else
      @set_cta = false
    end
      
    sql = %q|SELECT m.id, first_name, last_name, t.id AS team_id, team_members.cnt AS num_mem, title, tr.created_at AS join_ts, launched, coms.cnt AS coms, ideas.cnt AS ideas, ans.cnt AS ans, visits.cnt AS visits, visit.last_visit, content.last_content, cta.scenario, cta.cta_time, next_scenario.scenario AS next_scenario
    FROM members m
    LEFT OUTER JOIN team_registrations AS tr ON tr.member_id = m.id
    LEFT OUTER JOIN (SELECT team_id, COUNT(*) AS cnt FROM team_registrations GROUP BY team_id) AS team_members ON team_members.team_id = tr.team_id
    LEFT OUTER JOIN teams AS t ON t.id = tr.team_id
    LEFT OUTER JOIN (SELECT member_id, team_id, COUNT(*) AS cnt FROM comments GROUP BY member_id, team_id) AS coms ON coms.member_id = m.id AND coms.team_id = tr.team_id
    LEFT OUTER JOIN (SELECT member_id, team_id, COUNT(*) AS cnt FROM bs_ideas GROUP BY member_id, team_id) AS ideas ON ideas.member_id = m.id AND ideas.team_id = tr.team_id
    LEFT OUTER JOIN (SELECT member_id, team_id, COUNT(*) AS cnt FROM answers GROUP BY member_id, team_id) AS ans ON ans.member_id = m.id AND ans.team_id = tr.team_id
    LEFT OUTER JOIN (SELECT member_id, team_id, action, COUNT(*) AS cnt FROM activities GROUP BY member_id, team_id, action HAVING action = 'team index') AS visits ON visits.member_id = m.id AND visits.team_id = tr.team_id
    LEFT OUTER JOIN (SELECT member_id, team_id, action, MAX(created_at) AS last_visit FROM activities GROUP BY member_id, team_id, action HAVING action = 'team index') AS visit ON visit.member_id = m.id AND visit.team_id = tr.team_id
    LEFT OUTER JOIN (SELECT member_id, team_id, MAX(created_at) AS last_content FROM team_content_logs GROUP BY member_id, team_id) AS content ON content.member_id = m.id AND content.team_id = tr.team_id
    LEFT OUTER JOIN (SELECT scenario, member_id, team_id, created_at AS cta_time FROM call_to_action_emails_sents WHERE id IN (SELECT MAX(id) AS last_id FROM call_to_action_emails_sents GROUP BY member_id, team_id)) AS cta ON cta.member_id = m.id AND cta.team_id = tr.team_id
    LEFT OUTER JOIN (SELECT scenario, member_id, team_id FROM call_to_action_queues) AS next_scenario ON next_scenario.member_id = m.id AND next_scenario.team_id = tr.team_id
    WHERE t.initiative_id IN (1,2)
    ORDER BY m.id
    |
    @team_stats = Member.find_by_sql( sql );
    
    # get members that don't belong to a team
    sql = %q|
    select m.id, first_name, last_name, im.initiative_id, coms.cnt, email, m.created_at AS registered, visits.cnt AS visits, visit.last_visit AS last_visit, cta.scenario, cta_time, next_scenario.scenario AS next_scenario
    FROM members m
    LEFT OUTER JOIN initiative_members AS im ON im.member_id= m.id
    LEFT OUTER JOIN (SELECT member_id, COUNT(*) AS cnt FROM comments GROUP BY member_id) AS coms ON coms.member_id = m.id

    LEFT OUTER JOIN (SELECT member_id, COUNT(*) AS cnt FROM activities GROUP BY member_id) AS visits ON visits.member_id = m.id
    LEFT OUTER JOIN (SELECT member_id, MAX(created_at) AS last_visit FROM activities GROUP BY member_id) AS visit ON visit.member_id = m.id
    LEFT OUTER JOIN (SELECT scenario, member_id, created_at AS cta_time FROM call_to_action_emails_sents WHERE id IN (SELECT MAX(id) AS last_id FROM call_to_action_emails_sents GROUP BY member_id)) AS cta ON cta.member_id = m.id

    LEFT OUTER JOIN (SELECT scenario, member_id, team_id FROM call_to_action_queues) AS next_scenario ON next_scenario.member_id = m.id AND next_scenario.team_id = im.initiative_id
    WHERE im.initiative_id IN (1,2)  
    AND m.id NOT IN (SELECT member_id FROM team_registrations)
    ORDER BY initiative_id, first_name, last_name
    |
    @no_team = Member.find_by_sql(sql)
    
    
  end
  
  def delay_test
    @time1 = Time.now
    sleep 10
    @time2 = Time.now
  end
  
  def generic_email
    
    if ! (params[:message].nil? && params[:subject].nil?)
      # This will process the recipients and make them available as @invite.recipients
      @invite = InviteEmail.new :sender => @member, :recipient_emails => params[:recipient_emails], :message=> params[:message], :check_size=>false
      @invite.valid?

      respond_to do |format|
        if @invite.errors.empty?
          if params[:send_now] != 'true'
            recipient =  @invite.recipients[0]
            logger.debug "Generate a sample email to #{recipient[:first_name]} at #{recipient[:email]}"
            @email = GenericMailer.generic_email(@member, recipient, params[:subject], params[:message] )
            format.html { render :action => "preview_invite_request", :layout => false } if request.xhr?
            format.html { render :action => "preview_invite_request", :layout => 'plan' }
          else
            @invite.recipients.each do |recipient|
              logger.debug "Send an email to #{recipient[:first_name]} at #{recipient[:email]}"
              GenericMailer.delay.generic_email(@member, recipient, params[:subject], params[:message] )
              logger.warn "Email sent to #{recipient[:first_name]} at #{recipient[:email]}"
            end
            format.html { render :action => "acknowledge_invite_request", :layout => false } if request.xhr?
            format.html { render :action => "acknowledge_invite_request", :layout => 'plan' }

          end
        else
          if !@invite.errors[:recipient_emails].nil? && @invite.errors[:recipient_emails].size() > 0 && request.xhr?
            format.html { render :action => "invite_request_email_errors", :layout => false }
          else
            format.json { render :text => [@invite.errors].to_json, :status => 409 }    
          end
        end
      end
    end
  end
  
  
  def seed_participant_stats_table
    resp = []
    #Team.where(:id=>10065).order('id ASC').each do |team|
    Team.order('id ASC').each do |team|
      puts "Processing teams id: #{team.id}"

      # for each team, get the distinct participants
      participant_ids = ActiveRecord::Base.connection.select_values("SELECT DISTINCT(member_id) FROM participation_events WHERE team_id = #{team.id};")
      puts "participant_ids: #{participant_ids}"
      #participant_ids = [1]
      participant_ids.each do |participant_id|

        logger.debug "participant_id: #{participant_id}"
        participant = Member.find_by_id(participant_id)
        next if participant.nil?

        puts "Create participant_stats record for team #{team.id} and member: #{participant.id}"

        stats_rec = ParticipantStats.find_by_member_id_and_team_id(participant.id, team.id) || ParticipantStats.new(:member_id => participant.id, :team_id => team.id)
        
        notify = NotificationRequest.find_by_member_id_and_team_id(participant.id, team.id)
        stats_rec.following = notify.nil? ? 0 : notify.report_type
        
        stats_rec.endorse = Endorsement.find_by_member_id_and_team_id(participant.id, team.id).nil? ? false : true

        # get the counts
        
        participation_counts = ActiveRecord::Base.connection.select_all(
        %Q|select 
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 100) AS proposal_views,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 101) AS question_views,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 11) AS friend_invites,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 3) AS talking_points,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 4) AS talking_point_edits,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 17) AS talking_point_ratings,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 19) AS talking_point_preferences,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 1) AS comments,
        (select count(id) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND event_id = 13) AS content_reports,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id}) AS points_total,        
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '1 days') AS points_days1,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '3 days') AS points_days3,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '7 days') AS points_days7,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '14 days') AS points_days14,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '28 days') AS points_days28,
        (select sum(points) from participation_events where team_id = #{team.id} and member_id = #{participant.id} AND created_at > now() - interval '90 days') AS points_days90
        |)[0]
        
        stats_rec.proposal_views = participation_counts['proposal_views'].to_i
        stats_rec.question_views = participation_counts['question_views'].to_i
        stats_rec.friend_invites = participation_counts['friend_invites'].to_i
        stats_rec.talking_points = participation_counts['talking_points'].to_i
        stats_rec.talking_point_edits = participation_counts['talking_point_edits'].to_i
        stats_rec.talking_point_ratings = participation_counts['talking_point_ratings'].to_i
        stats_rec.talking_point_preferences = participation_counts['talking_point_preferences'].to_i
        stats_rec.comments = participation_counts['comments'].to_i
        stats_rec.content_reports = participation_counts['content_reports'].to_i

        stats_rec.points_total = participation_counts['points_total'].to_i
        stats_rec.points_days1 = participation_counts['points_days1'].to_i
        stats_rec.points_days3 = participation_counts['points_days3'].to_i
        stats_rec.points_days7 = participation_counts['points_days7'].to_i
        stats_rec.points_days14 = participation_counts['points_days14'].to_i
        stats_rec.points_days28 = participation_counts['points_days28'].to_i
        stats_rec.points_days90 = participation_counts['points_days90'].to_i

        resp.push(stats_rec.inspect)
      ## I can set last_visit and save, but it breaks inspect
        last_visit = ParticipationEvent.where(:member_id => 1, :team_id => team.id).last
        stats_rec.last_visit = last_visit.nil? ? nil : last_visit.created_at
        stats_rec.save
        
      end
    end
    render :text=> resp.join('\n').gsub(/,/,",\n"), :content_type => 'text/plain'
    puts "XXXX\nXXXX\nXXXX\nXXXX\nXXXX\n"
  end

  def seed_proposal_stats_table
    #Team.where(:id=>10065).order('id ASC').each do |team|  
    Team.order('id ASC').each do |team|
      puts "Processing teams id: #{team.id}"

      stats_rec = ProposalStats.find_by_team_id(team.id) || ProposalStats.new(:team_id => team.id)
      stats_rec.participants = ActiveRecord::Base.connection.select_value("SELECT COUNT(DISTINCT(member_id)) FROM participation_events WHERE team_id = #{team.id};").to_i
      
      participation_counts = ActiveRecord::Base.connection.select_all(
      %Q|SELECT SUM(points_total) AS points_total, SUM(points_days1) AS points_days1, SUM(points_days3) AS points_days3, SUM(points_days7) AS points_days7, 
      SUM(points_days14) AS points_days14, SUM(points_days28) AS points_days28, SUM(points_days90) AS points_days90 FROM participant_stats WHERE team_id = #{team.id}|)[0]
      
      stats_rec.points_total = participation_counts['points_total'].to_i
      stats_rec.points_days1 = participation_counts['points_days1'].to_i
      stats_rec.points_days3 = participation_counts['points_days3'].to_i
      stats_rec.points_days7 = participation_counts['points_days7'].to_i
      stats_rec.points_days14 = participation_counts['points_days14'].to_i
      stats_rec.points_days28 = participation_counts['points_days28'].to_i
      stats_rec.points_days90 = participation_counts['points_days90'].to_i
      
      stats = []
      event_records = ActiveRecord::Base.connection.select_rows("SELECT event_id, COUNT(id), SUM(points) FROM participation_events WHERE team_id = #{team.id} GROUP BY event_id")
      event_records.each do |er| 
      	pep = PARTICIPATION_EVENT_POINTS["item#{er[0]}"]
      	stats.push(:title => pep['summary_title'], :count => er[1], :points => er[2], :order=>pep['summary_order'], :col_name => pep['col_name'])
      end
      
      stats.each do |stat|
        stats_rec[stat[:col_name]] = stat[:count].to_i unless stat[:col_name] == ''
      end
      
      # estimate the base for views
      stats_rec.proposal_views_base = 
        stats_rec.endorsements * 5  +
        stats_rec.talking_points * 8 +
        stats_rec.comments * 4 +
        stats_rec.participants * 4 +
        stats_rec.followers * 4

      stats_rec.question_views_base = 
        stats_rec.endorsements * 3  +
        stats_rec.talking_points * 6 +
        stats_rec.comments * 4
      
      puts stats_rec.inspect
      
      stats_rec.save
    end
    render :text => 'seed_proposal_stats_table completed'
  end
  
  protected
    
    def get_admin_privileges
      #debugger
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