namespace :ce_live_testing do

  task :session_test, [:channel, :session_id, :group_range] => :environment do |t,args|
    
    r = args.group_range.split('..').map{|d| Integer(d)}
    
    puts "Run session_test for session: #{args.session_id}, with groups: #{args.group_range} on channel: #{args.channel}"
    ltps = LiveTalkingPoint.where(:live_session_id => args.session_id.to_i, :group_id => r[0]..r[1] )
    ctr = 1
    puts "There are #{ltps.size} live talking points"
    ltps.shuffle.each do |ltp|
      ltp.text = "\##{ctr}: #{ltp.text}"
      ctr += 1
      Juggernaut.publish(args.channel, {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
      sleep( (Random.new.rand(2..8)).seconds )
    end
  end
  

end
