desc "Find all the emails that were sent to team_members by Admin"
task :extract_cta_from_log => :environment do
  puts "Extract admin email recipients"
  
  in_email_rec = false
  
  rec_ctr = 1;
  sent_date = nil
  filepath = "/ce_development/temp/2029 prod logs/10.18-11.16/Log"
  line = nil
  
  begin
    File.open(filepath) do |file|
      file.each_line do |line|
        if line.match(/AdminController#email/)
          in_email_rec = true
          #puts line
          sent_date = line.match(/(2010-[^\)]*)/)[0]
        elsif in_email_rec
          if line.match(/^\s*Parameters:/)
            if line.match(/"act"=>"send"/)
              #puts line
              subject = line.match(/"subject"=>"([^"]*)"/)[1]            
              team_id = line.match(/"team_id"=>"(\d+)/)[1]
              # "recip_ids"=>"21" or "recip_ids"=>["1","2"]
              recip_ids = line.match(/"recip_ids"=>"([^"]*)/)
              if recip_ids.nil?
                puts '**** recip_ids is nil'
                recip_ids = line.match(/"recip_ids"=>\[([^\]]*)/)[1]
                puts "**** recip_ids: #{recip_ids}"
                # "1", "2"...
                recip_ids = recip_ids.gsub(/"/,'')
              else
                recip_ids = recip_ids[1]
              end
              if recip_ids != '1'
                puts "recip_ids: #{recip_ids}, #{recip_ids.class}"
                recip_ids = recip_ids.split(',')
                recip_ids.each do |recip_id|
                  recip_id = recip_id.to_i
                  if recip_id > 3
                    puts "#{rec_ctr} Sent email #{subject} to id: #{recip_id} in team: #{team_id} on #{sent_date}"
                    ctae = CallToActionEmailsSent.new(
                      :member_id=> recip_id, 
                      :scenario=> subject,
                      :version=> 0,
                      :team_id=> team_id
                    )
                    ctae.save
                    rec_ctr += 1
                  end
                end
                #exit if rec_ctr > 10 
              end
            end
            in_email_rec = false
          end
        
        else
          in_email_rec = false
        end
      end
    end
  #rescue
  #  puts "Failed on line: #{line}"
  #  exit
  end
  
end
