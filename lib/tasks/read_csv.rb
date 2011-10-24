#!/usr/bin/env ruby

filename = "/ce assets/2011/JHK/istorm data/Citizen Parliament - ISTORM results.csv"

require 'csv'

CSV.foreach(filename) do |row|
  puts row[0]
  
  if !row[0].nil?
    if row[0].match(/Scribe/)
    	group_id = row[0].match(/\d+/)[0].to_i
    	puts "Save a record for group #{group_id}"
    	row.each_index do |index|
    	  if index > 0 && !row[index].nil?
    	    ltp = LiveTalkingPoint.new :session_id=>index, :group_id => group_id, :text => row[index]
    	    puts ltp
  	    end
  	  end
    	# for every non blank fied, make a live_talking_point
    elsif row[0].match(/Theme/)
    	themer_id = row[0].match(/\d+/)[0].to_i
    	puts "Save a record for group #{themer_id}"
    elsif row[0].match(/Coordinator/)
    	puts "save a record for Coordinator"
  
    end
  end
  
  
  
end
