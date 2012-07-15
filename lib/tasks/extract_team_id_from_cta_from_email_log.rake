desc "Find all the emails that were sent to team_members by Admin"
task :extract_team_id_from_cta_from_email_log => :environment do
  puts "Extract admin email recipients"
  
  in_email_rec = false
  
  rec_ctr = 1;
  sent_date = nil
  filepath = "#{Rails.root}/lib/tasks/prod_log"
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
              # "recip_ids"=>"21" or "recip_ids"=>["1","2"]
              scenario = line.match(/"scenario"=>"([^"]*)/)[1]
              #"recip_ids"=>["117-10034", "118-10034", "127-10034", "141-10034", "49-10019", ..., "126-10022"]
              recip_ids = line.match(/"recip_ids"=>\[([^\]]*)/)
              #puts "#{scenario} sent to #{recip_ids}"
              recip_ids.to_s.scan(/(\d+)-(\d+)/).each do |member_id, team_id|
                if member_id != '1' && member_id != '119'
                  puts "update member #{member_id} with #{team_id} for scenario #{scenario}" 
                  ctaes = CallToActionEmailsSent.find_by_member_id(member_id, :conditions=>"team_id IS NULL AND scenario ~* '#{scenario}'")
                  if ctaes.nil?
                    scenario.gsub!(/ 2029/,'')
                    ctaes = CallToActionEmailsSent.find_by_member_id(member_id, :conditions=>"team_id IS NULL AND scenario ~* '#{scenario}'")
                  end
                  ctaes.team_id = team_id
                  puts ctaes.inspect
                  ctaes.save
                end
              end
              #if recip_ids.nil?
              #  puts '**** recip_ids is nil'
              #  recip_ids = line.match(/"recip_ids"=>\[([^\]]*)/)[1]
              #  puts "**** recip_ids: #{recip_ids}"
              #  # "1", "2"...
              #  recip_ids = recip_ids.gsub(/"/,'')
              #else
              #  recip_ids = recip_ids[1]
              #end
              #if recip_ids != '1'
              #  puts "recip_ids: #{recip_ids}, #{recip_ids.class}"
              #  recip_ids = recip_ids.split(',')
              #  recip_ids.each do |recip_id|
              #    recip_id = recip_id.to_i
              #    if recip_id > 3
              #      puts "#{rec_ctr} Sent email #{subject} to id: #{recip_id} in team: #{team_id} on #{sent_date}"
              #      ctae = CallToActionEmailsSent.new(
              #        :member_id=> recip_id, 
              #        :scenario=> subject,
              #        :version=> 0,
              #        :team_id=> team_id
              #      )
              #      ctae.save
              #      rec_ctr += 1
              #    end
              #  end
              #  #exit if rec_ctr > 10 
              #end
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
