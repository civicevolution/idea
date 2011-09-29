class NotificationRequest < ActiveRecord::Base
 
  attr_accessor :reply_freq
  attr_accessor :reply_format
  attr_accessor :com_freq
  attr_accessor :com_format
  attr_accessor :tp_freq
  attr_accessor :tp_format
  attr_accessor :act
  attr_accessor :follow
  attr_accessor :follow_freq
    
  after_initialize :init_settings
  
    
  # save notification settings as notification requests
  # report_type: 1 = replies, 2 = all
  # report_format: 1 = full, 2 = summary
  # there can be 0,1, or 2 records
  # freq: n = never, i = immediate, h = hourly, d = daily (1 entry in hours)
  #  id |       type        |    description     
  # ----+-------------------+--------------------
  #   0 | my content
  #   1 | question          | question           
  #   2 | answer            | answer             
  #   3 | comment           | comment            
  #   4 | team              | team               
  #   5 | chat_session      | chat_session       
  #   6 | chat_message      | chat_message       
  #   7 | list              | list               
  #   8 | list_item         | list_item          
  #   9 | page              | page               
  #  10 | team info         | team info          
  #  11 | public_discussion | public_discussion  
  #  12 | bs_idea           | Brainstorming idea 
  #  13 | talking_point     | talking_point
  
  # after_initialize sets the vars I need to adjust settings in browser
  
  # simpify this to a single report with a frequency of immediately, hourly, daily, weekly, never
  
  def init_settings
    if self.act == 'init' && !self.member_id.nil? && !self.team_id.nil?
      logger.debug "after_initialize new notification_request"
      self.follow = false
      self.reply_freq = 'n'
      self.reply_format = 'full'
      self.com_freq = 'n'
      self.com_format = 'full'
      self.tp_freq = 'n'
      self.tp_format = 'full'
      self.follow_freq = 'd'
      recs = NotificationRequest.find_all_by_member_id_and_team_id(self.member_id, self.team_id)

      recs.each do |req|
        req.hour_to_run = req.hour_to_run.scan(/\d+/).map{|d| d.to_i} unless req.hour_to_run.nil?
        case 
          when req.report_type == 4 # replies to my content
            case
              when req.immediate
                self.follow_freq = 'i'
              when req.dow_to_run.nil? && req.hour_to_run.nil?
                self.follow_freq = 'h'
              when req.dow_to_run.nil? && req.hour_to_run.size == 1
                self.follow_freq = 'd'
              when req.dow_to_run.size == 1 && req.hour_to_run.size == 1
                self.follow_freq = 'w'
            end
          
          #when req.report_type == 0 # replies to my content
          #  case
          #    when req.immediate
          #      self.reply_freq = 'i'
          #    when req.dow_to_run.nil? && req.hour_to_run.nil?
          #      self.reply_freq = 'h'
          #    when req.dow_to_run.nil? && req.hour_to_run.size == 1
          #      self.reply_freq = 'd'
          #  end
          #  self.reply_format = req.report_format == 1 ? 'full' : 'sum'
          #when req.report_type == 3 # all comments
          #  case
          #    when req.immediate
          #      self.com_freq = 'i'
          #    when req.dow_to_run.nil? && req.hour_to_run.nil?
          #      self.com_freq = 'h'
          #    when req.dow_to_run.nil? && req.hour_to_run.size == 1
          #      self.com_freq = 'd'
          #  end          
          #  self.com_format = req.report_format == 1 ? 'full' : 'sum'
          #when req.report_type == 4 # follow this idea
          #  self.follow = true
          #when req.report_type == 13 # all talking points
          #  case
          #    when req.immediate
          #      self.tp_freq = 'i'
          #    when req.dow_to_run.nil? && req.hour_to_run.nil?
          #      self.tp_freq = 'h'
          #    when req.dow_to_run.nil? && req.hour_to_run.size == 1
          #      self.tp_freq = 'd'
          #  end          
          #  self.tp_format = req.report_format == 1 ? 'full' : 'sum'
          #
        end # end case type        
      end # end do req
    end # end if member & team_id
  end
  
  
  # before_save - convert the form attribute to record attributes and save as 2 records
  #def before_save
  def split_n_save
    if self.act == 'split_save'

      logger.debug "convert this into actual records and store as two records - somehow"    
    
      # there may be 0,1, or 2 records for this request already
      # save first record as reply and second record as all
      
      recs = NotificationRequest.find_all_by_member_id_and_team_id(self.member_id, self.team_id)
      
      # create/adjust comments
      rec = recs.detect{|r| r.report_type == 4} || NotificationRequest.new( :member_id=>self.member_id, :team_id=>self.team_id, :report_type=>4 )
      rec.report_format = 1 # full report
      case self.follow_freq
        when 'i'
          rec.immediate = true
          rec.hour_to_run = nil
          rec.dow_to_run = nil          
        when 'h'
          rec.immediate = false        
          rec.hour_to_run = nil
          rec.dow_to_run = nil          
        when 'd'
          rec.immediate = false
          rec.hour_to_run = '{18}'
          rec.dow_to_run = nil          
        when 'w'
          rec.immediate = false
          rec.hour_to_run = '{18}'
          rec.dow_to_run = '{6}'          
        when 'n'
          # delete this record
          rec.destroy
          rec = nil
          save_follow = true
      end
      save_follow = rec.save unless rec.nil?
      return save_follow
      

      ## create/adjust reply first
      #rec = recs.detect{|r| r.report_type == 0} || NotificationRequest.new( :member_id=>self.member_id, :team_id=>self.team_id, :report_type=>0 )
      #rec.report_format = self.reply_format == 'full' ? 1 : 2
      #case self.reply_freq
      #  when 'i'
      #    rec.immediate = true
      #    rec.hour_to_run = nil
      #    rec.dow_to_run = nil          
      #  when 'h'
      #    rec.immediate = false        
      #    rec.hour_to_run = nil
      #    rec.dow_to_run = nil          
      #  when 'd'
      #    rec.immediate = false
      #    rec.hour_to_run = '{18}'
      #    rec.dow_to_run = nil          
      #  when 'n'
      #    # delete this record
      #    rec.destroy
      #    rec = nil
      #    save0 = true
      #end
      #save0 = rec.save unless rec.nil?
      #
      ## create/adjust comments
      #rec = recs.detect{|r| r.report_type == 3} || NotificationRequest.new( :member_id=>self.member_id, :team_id=>self.team_id, :report_type=>3 )
      #rec.report_format = self.com_format == 'full' ? 1 : 2
      #case self.com_freq
      #  when 'i'
      #    rec.immediate = true
      #    rec.hour_to_run = nil
      #    rec.dow_to_run = nil          
      #  when 'h'
      #    rec.immediate = false        
      #    rec.hour_to_run = nil
      #    rec.dow_to_run = nil          
      #  when 'd'
      #    rec.immediate = false
      #    rec.hour_to_run = '{18}'
      #    rec.dow_to_run = nil          
      #  when 'n'
      #    # delete this record
      #    rec.destroy
      #    rec = nil
      #    save3 = true
      #end
      #save3 = rec.save unless rec.nil?
      #
      ## create/adjust follow
      #rec = recs.detect{|r| r.report_type == 4} || NotificationRequest.new( :member_id=>self.member_id, :team_id=>self.team_id, :report_type=>4 )
      #if self.follow.to_i == 1 
      #  save4 = rec.save
      #else
      #  rec.destroy
      #  save4 = true
      #end
      #
      #
      ## create/adjust comments
      #rec = recs.detect{|r| r.report_type == 13} || NotificationRequest.new( :member_id=>self.member_id, :team_id=>self.team_id, :report_type=>13 )
      #rec.report_format = self.tp_format == 'full' ? 1 : 2
      #case self.tp_freq
      #  when 'i'
      #    rec.immediate = true
      #    rec.hour_to_run = nil
      #    rec.dow_to_run = nil          
      #  when 'h'
      #    rec.immediate = false        
      #    rec.hour_to_run = nil
      #    rec.dow_to_run = nil          
      #  when 'd'
      #    rec.immediate = false
      #    rec.hour_to_run = '{18}'
      #    rec.dow_to_run = nil          
      #  when 'n'
      #    # delete this record
      #    rec.destroy
      #    rec = nil
      #    save13 = true
      #end
      #save13 = rec.save unless rec.nil?
      #
      #return save0 && save3 && save4 && save13
    end # end if split_save
  end
  


  def self.check_team_content_log(logger = logger, test_mode = false)
    # check if there are any new immediate records and to see if anyone is listening to them
    logger.debug "NotificationRequest.check_team_content_log @ #{Time.now}"
    new_logs = TeamContentLog.all(:conditions=>'processed=false',:limit=>50)
    if new_logs.size>0
      logger.debug "There are #{new_logs.size} new entries to check"
      new_logs.each do |log_record|
        team = entry = nil
      
        requests = NotificationRequest.all( 
          :conditions=>['team_id = ? AND (report_type = 4)',log_record.team_id],
          :order=>'member_id, report_type' )
        logger.debug "There are #{requests.size} notification requests to process"
        # one user could match 2x : give precedence to immediate if it is sent
        # don't send the same item 2x immediately
        # report_type = 1 (reply) doesn't apply if member is the author
        immed_send_mem_id = nil
        
        requests.each do |request|
        
          logger.info "I found a match for member #{request.member_id} 2: #{immed_send_mem_id}"
          #if request.immediate
          if false # never send as immediate while I generate TP
            if request.member_id == log_record.member_id 
              logger.debug "Don't report immediately, it is my comment"
            elsif immed_send_mem_id == request.member_id
              logger.debug "Don't report immediately, it's has already been reported immediately as a reply"
            else
              logger.debug "Send this report immediately to #{request.member_id} as report_type: #{request.report_type}"
              team ||= Team.first(:select=>'id, title, initiative_id', :conditions=> {:id=>request[:team_id]} )
            
              if request.report_format == 1
                # make sure I have the necessary data for a full report
                case
                  when log_record.o_type ==  2
                    entry = Answer.find_by_id(log_record.o_id)
                  when log_record.o_type ==  3
                    entry = Comment.find_by_id(log_record.o_id)
                  when log_record.o_type ==  12
                    entry = BsIdea.find_by_id(log_record.o_id)
                  when log_record.o_type ==  13
                    entry = TalkingPoint.find_by_id(log_record.o_id)
                end # end case
              end # end if 1 (full)
              #recipient = Member.first(:select=>'first_name, last_name, email', :conditions=>{:id=>request.member_id})
              recipient = Member.select('id, first_name, last_name, email, location').where(:id=>request.member_id).first

              logger.debug "NotificationRequest Send an email for entry #{entry.inspect} to #{recipient.email} at #{Time.now}."
              mcode,mcode_id = MemberLookupCode.get_code_and_id(recipient.id, {:scenario=>'immediate report'})
              
              case team.initiative_id
                when 1
                  subdomain = 'cgg.'
                when 2
                  subdomain = '2029.'
                else
                  subdomain = ''
              end
              host = subdomain + (RAILS_ENV == 'development' ? 'civicevolution.dev' : 'civicevolution.org')

              if !test_mode
                NotificationMailer.immediate_report(recipient, team, request, entry, mcode, host).deliver unless team.nil? || entry.nil?
                  #unless RAILS_ENV=='development' && recipient.email.match(/civicevolution.org/).nil?
              else
                log_record.update_attribute('processed',true)
                return recipient, team, request, entry, mcode, host
              end
              immed_send_mem_id = request.member_id #if request.report_type
            end
          else
            logger.debug "Queue this request to queue: #{request.match_queue}"

            # I want to concatenate type-id to the queue
            #request.update("UPDATE notification_requests SET match_queue = array_append(match_queue, '#{log_record.o_type}-#{log_record.o_id}') where id = #{request.id}",)
            if request.match_queue.nil?
              match_queue = "{#{log_record.o_type}-#{log_record.o_id}}"
            else
              match_queue = request.match_queue.sub(/\}/,",#{log_record.o_type}-#{log_record.o_id}}")
            end
            logger.debug "match_queue: #{match_queue}"
            request.update_attribute('match_queue',match_queue)
          end
        end # end each request
        log_record.update_attribute('processed',true)
      end # end each log_record
    end
    #logger.info "\n NotificationRequest EXIT  check_team_content_log at #{Time.now}."        
  
  end

  def self.send_periodic_report(dow = 5, hod = 13, logger = logger, test_mode = false)
    logger.debug "NotifiationRequest.send_periodic_report"
    
    return
    
    #reports = NotificationRequest.all(
    #  :conditions=>['match_queue IS NOT NULL AND (hour_to_run IS NULL OR ? = ANY (hour_to_run) ) AND (dow_to_run IS NULL OR ? = ANY (dow_to_run) )',hod, dow ],
    #  :order=>"member_id, team_id, report_type"
    #)
    
    #reports = NotificationRequest.where(
    #  ['match_queue IS NOT NULL AND (hour_to_run IS NULL OR ? = ANY (hour_to_run) ) AND (dow_to_run IS NULL OR ? = ANY (dow_to_run) )',hod, dow ]
    #  ).order("member_id, team_id, report_type")  
    #
    # send all queued reports
    reports = NotificationRequest.where( 'match_queue IS NOT NULL' ).order("member_id, team_id, report_type")  

      
    return if reports.size == 0
    
    # collect all the item ids I will reference
    team_ids = []
    recip_ids = []
    member_ids = []
    displayed_objects = {'2'=>[], '3'=>[], '13'=>[]}
    recipient_reports = []
    recipient_requests = []
    # and combine reports for the same member
    
    mem_id = nil
    reports.each do |report| 
      logger.debug "Collect ids for this report: #{report.inspect}"
      team_ids.push report.team_id
      
      recip_ids.push report.member_id
      if report.report_format == 1 # only collect ids of elements shown in full display
        report.match_queue.scan(/(\d+)-(\d+)/).each do |item_type, item_id|
          #logger.debug "Find type: #{item_type}, id: #{item_id}"
          displayed_objects[item_type].push item_id
        end 
      end
      
      #logger.debug "Check if I have seem this member (#{report.member_id}) already"
      if mem_id == report.member_id
        recipient_requests.push report
      else
        #logger.debug "New member"
        mem_id = report.member_id
        recipient_requests = [report]
        recipient_reports.push recipient_requests
      end
    end
    
    #logger.debug "displayed_objects: #{displayed_objects}"

    # collect all the data I will use
    @teams = Team.find(:all, :select=>'id, title, initiative_id', :conditions=> { :id=>team_ids} )

    @recipients = Member.find(:all, :select=>'id, first_name, last_name, email, location', :conditions=> { :id=>recip_ids} )
    # get the unique locations that need to be converted and create the location objects
    locations = {}
    @recipients.collect{|r| r.location.gsub(' ','_')}.uniq.each{ |l| locations[l] = TZInfo::Timezone.get(l)}

    # locations['Australia/Perth'] ... locations[recipient.location]
    @comments = displayed_objects['3'].size == 0 ? [] : Comment.find_all_by_id(displayed_objects['3'].uniq)
    #@comments =  displayed_objects['3'].size == 0 ? [] : Comment.all(
    #  :select => 'c.id, text, c.updated_at, first_name, last_name, team_id',
    #  :conditions => { 'c.id'=>displayed_objects['3'].uniq},
    #  :joins => 'as c inner join members as m on m.id = c.member_id' 
    #) 
    # convert the comment updated_at timestamp for each location
    @comments.each do |c|
      c[:tz] = {}
      locations.each{|id,tz| c[:tz][id] = tz.utc_to_local(c.updated_at) }
    end
    
    @answers = displayed_objects['2'].size == 0 ? [] : Answer.find_all_by_id(displayed_objects['2'].uniq)
    @answers.each do |a|
      a[:tz] = {}
      locations.each{|id,tz| a[:tz][id] = tz.utc_to_local(a.updated_at) }
    end

    #@bs_ideas = displayed_objects['12'].size == 0 ? [] : BsIdea.find_all_by_id(displayed_objects['12'].uniq)
    #@bs_ideas.each do |b|
    #  b[:tz] = {}
    #  locations.each{|id,tz| b[:tz][id] = tz.utc_to_local(b.updated_at) }
    #end    
    
    @talking_points = displayed_objects['13'].size == 0 ? [] : TalkingPoint.find_all_by_id(displayed_objects['13'].uniq)
    @talking_points.each do |tp|
      tp[:tz] = {}
      locations.each{|id,tz| tp[:tz][id] = tz.utc_to_local(tp.updated_at) }
    end    

    @teams.each do |team|
      case team.initiative_id
        when 1
          subdomain = 'cgg.'
        when 2
          subdomain = '2029.'
        else
          subdomain = ''
      end
      team['host'] = subdomain + (RAILS_ENV == 'development' ? 'civicevolution.dev' : 'civicevolution.org')
    end

    recipient_reports.each do |reports| 
      #logger.debug "Email this: #{reports.inspect}"
      recipient = @recipients.detect{|r| r.id == reports[0].member_id}
      mcode = MemberLookupCode.get_code(recipient.id, {:scenario=>'periodic team report'} )
      if !test_mode
        NotificationMailer.periodic_report(recipient, @teams, @comments, @answers, @talking_points, reports, mcode).deliver
          #unless RAILS_ENV=='development' && recipient.email.match(/civicevolution.org/).nil?
      else
        return recipient, @teams, @comments, @answers, @talking_points, reports, mcode
      end
        
        
      # uncomment update line to clear the queue
      reports.each do |request|
        ActiveRecord::Base::connection().update("update notification_requests set match_queue = null, sent_time = now() at time zone 'UTC' where id = #{request.id}");
      end
    end
    
  end


  
end
