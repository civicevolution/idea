namespace :update_live_talking_points do
  task :add_id_and_votes => :environment do
    puts 'update_live_talking_points'
 
    ltps = LiveTalkingPoint.order('live_session_id, group_id, id')
    
    puts "There are #{ltps.size} live talking points"  
    group_id = -1
    letter = 'A'
    ltps.each do |ltp|
      if ltp.group_id != group_id
        letter = 'A' 
        group_id = ltp.group_id
      else
        letter.next!
      end
      ltp.id_letter = letter
      
      if rand > 0.2
        pro = [*4..7].sample
      else
        pro = [*1..4].sample
      end
      ltp.pos_votes = pro
      ltp.neg_votes = 7 - pro
      
      ltp.save
      puts ltp.inspect

    end
  end

    
end
  
  