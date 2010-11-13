class NotificationRequest < ActiveRecord::Base
 
  attr_accessor :reply_freq
  attr_accessor :reply_format
  attr_accessor :all_freq
  attr_accessor :all_format
  attr_accessor :act
  
  
    
  # save notification settings as notification requests
  # report_type: 1 = replies, 2 = all
  # report_format: 1 = full, 2 = summary
  # there can be 0,1, or 2 records
  # freq: n = never, i = immediate, h = hourly, d = daily (1 entry in hours)
  
  # after_initialize sets the vars I need to adjust settings in browser
  def after_initialize
    if self.act == 'init' && !self.member_id.nil? && !self.team_id.nil?
      logger.debug "after_initialize new notification_request"
      self.reply_freq = 'n'
      self.reply_format = 'full'
      self.all_freq = 'n'
      self.all_format = 'full'
      recs = NotificationRequest.find_all_by_member_id_and_team_id(self.member_id, self.team_id)
      #debugger
      recs.each do |req|
        req.hour_to_run = req.hour_to_run.scan(/\d+/).map{|d| d.to_i} unless req.hour_to_run.nil?
        case 
          when req.report_type == 1 # replies
            case
              when req.immediate
                self.reply_freq = 'i'
              when req.dow_to_run.nil? && req.hour_to_run.nil?
                self.reply_freq = 'h'
              when req.dow_to_run.nil? && req.hour_to_run.size == 1
                self.reply_freq = 'd'
            end
            self.reply_format = req.report_format == 1 ? 'full' : 'sum'
          when req.report_type == 2 # all
            case
              when req.immediate
                self.all_freq = 'i'
              when req.dow_to_run.nil? && req.hour_to_run.nil?
                self.all_freq = 'h'
              when req.dow_to_run.nil? && req.hour_to_run.size == 1
                self.all_freq = 'd'
            end          
            self.all_format = req.report_format == 1 ? 'full' : 'sum'
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
      # create/adjust reply first
      rec = recs.detect{|r| r.report_type == 1} || NotificationRequest.new( :member_id=>self.member_id, :team_id=>self.team_id, :report_type=>1 )
      rec.report_format = self.reply_format == 'full' ? 1 : 2
      case self.reply_freq
        when 'i'
          rec.immediate = true
        when 'h'
          rec.immediate = false        
          rec.hour_to_run = nil
          rec.dow_to_run = nil          
        when 'd'
          rec.immediate = false
          rec.hour_to_run = '{18}'
          rec.dow_to_run = nil          
        when 'n'
          # delete this record
          rec.destroy
          rec = nil
      end
      rec.save unless rec.nil?

      # create/adjust all
      rec = recs.detect{|r| r.report_type == 2} || NotificationRequest.new( :member_id=>self.member_id, :team_id=>self.team_id, :report_type=>2 )
      rec.report_format = self.all_format == 'full' ? 1 : 2
      case self.all_freq
        when 'i'
          rec.immediate = true
        when 'h'
          rec.immediate = false        
          rec.hour_to_run = nil
          rec.dow_to_run = nil          
        when 'd'
          rec.immediate = false
          rec.hour_to_run = '{18}'
          rec.dow_to_run = nil          
        when 'n'
          # delete this record
          rec.destroy
          rec = nil
      end
      rec.save unless rec.nil?
      
      #return false if self.act == 'split_save'
    end # end if split_save
  end
  


  def self.check_team_content_log(logger = logger)
    # check if there are any new immediate records and to see if anyone is listening to them
    logger.debug "NotificationRequest.check_team_content_log @ #{Time.now}"
    new_logs = TeamContentLog.all(:conditions=>'processed=false',:limit=>50)
    if new_logs.size>0
      logger.debug "There are #{new_logs.size} new entries to check"
      new_logs.each do |log_record|
        team = entry = nil
      
        requests = NotificationRequest.all( 
          :conditions=>['team_id = ? AND (report_type = 2 OR member_id = ?)',log_record.team_id, log_record.par_member_id],
          :order=>'member_id, report_type' )
        logger.debug "There are #{requests.size} notification requests to process"
        # one user could match 2x : give precedence to immediate if it is sent
        # don't send the same item 2x immediately
        # report_type = 1 (reply) doesn't apply if member is the author
        immed_send_mem_id = nil
        requests.each do |request|
        
          logger.info "I found a match for member #{request.member_id} 2: #{immed_send_mem_id}"
          if request.immediate
            if request.member_id == log_record.member_id 
              logger.debug "Don't report immediately, it is my comment"
            elsif immed_send_mem_id == request.member_id
              logger.debug "Don't report immediately, it's has already been reported immediately as a reply"
            else
              logger.debug "Send this report immediately to #{request.member_id} as report_type: #{request.report_type}"
              team ||= Team.first(:select=>'id, title', :conditions=> {:id=>request[:team_id]} )
            
              if request.report_format == 1
                # make sure I have the necessary data for a full report
                case
                  when log_record.o_type ==  2
                    entry ||= Answer.find(log_record.o_id)
                  when log_record.o_type ==  3
                    entry ||= Comment.first(
                      :select => 'c.id, text, c.updated_at, first_name, last_name',
                      :conditions => { 'c.id'=>log_record.o_id},
                      :joins => 'as c inner join members as m on m.id = c.member_id' 
                    )
                  when log_record.o_type ==  11
                    entry ||= BsIdea.find(log_record.o_id)
                end # end case
              end # end if 1 (full)
              recipient = Member.first(:select=>'first_name, last_name, email', :conditions=>{:id=>request.member_id})
              logger.debug "NotificationRequest Send an email for entry #{entry.inspect} to #{recipient.email} at #{Time.now}."
            
              NotificationMailer.deliver_immediate_report(recipient, team, request, entry)
            
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

  def self.send_periodic_report(hod = 13, dow = 5)
    logger.debug "NotifiationRequest.send_periodic_report"
    
    reports = NotificationRequest.all(
      :conditions=>['match_queue IS NOT NULL AND (hour_to_run IS NULL OR ? = ANY (hour_to_run) ) AND (dow_to_run IS NULL OR ? = ANY (dow_to_run) )',hod, dow ],
      :order=>"member_id, team_id, report_type"
    )  
    return if reports.size == 0
    
    # collect all the item ids I will reference
    team_ids = []
    recip_ids = []
    member_ids = []
    displayed_objects = {'2'=>[], '3'=>[], '11'=>[]}
    
    # and combine reports for the same member
    
    mem_id = nil
    reports.each do |report| 
      #logger.debug "Collect ids for this report: #{report.inspect}"
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
        #logger.debug "combine records"
        # I have already processed this member record once, combine this record with the earlier one
        member_report = reports.detect{|r| r.member_id == report.member_id && r.id != report.id}
        #logger.debug "concatenate rec #{report.id} and #{member_report.id}"
        # concatenate the match_queues
        #member_report.match_queue = member_report.match_queue.sub(/\}/, ',' + report.match_queue.sub(/\{/,'').sub(/\}/,'') + '}')
        
        # add the new report to the first report, and ignore subsequent reports to this member in email loop
        member_report[:report] = report
        report[:ignore] = true
      else
        #logger.debug "New member"
        mem_id = report.member_id
      end
    end
    
    #logger.debug "displayed_objects: #{displayed_objects}"

    # collect all the data I will use
    @teams = Team.find(:all, :select=>'id, title', :conditions=> { :id=>team_ids} )
    @recipients = Member.find(:all, :select=>'id, first_name, last_name, email', :conditions=> { :id=>recip_ids} )
    @comments = Comment.all(
      :select => 'c.id, text, c.updated_at, first_name, last_name',
      :conditions => { 'c.id'=>displayed_objects['3'].uniq},
      :joins => 'as c inner join members as m on m.id = c.member_id' 
    )  if displayed_objects['3'].size > 0
    @answers = Answer.find_all_by_id(displayed_objects['2'].uniq) if displayed_objects['2'].size > 0
    @bs_ideas = BsIdea.find_all_by_id(displayed_objects['11'].uniq) if displayed_objects['11'].size > 0
    
    reports.each do |report| 
      if report[:ignore].nil?
        logger.debug "Email this: #{report.inspect}"
        #report.match_queue = report.match_queue.scan(/\d+-\d+/).map{|d| d} 
    
        NotificationMailer.deliver_periodic_report(@recipients.detect{|r| r.id == report.member_id}, @teams.detect{|t| t.id == report.team_id}, @comments, @answers, @bs_ideas,report)
      end
      # uncomment update line to clear the attributes
      #report.update_attributes( {:match_queue=>nil, :sent_time=>Time.now.utc} )
      #NotificationRequest.update( "update notification_requests set match_queue = null, sent_time = now() at time zone 'UTC' where id = #{report.id}",'update' );
      ActiveRecord::Base::connection().update("update notification_requests set match_queue = null, sent_time = now() at time zone 'UTC' where id = #{report.id}");
    end
  end


  
end
