# rake s3_move_thumbnails
task :s3_move_thumbnails => :environment do
  require 'rubygems'
  require 'aws-sdk'
  
  
  
  puts "Move the thumbnails in S3"
  
  puts 'read apecode for user'
  members = Member.all
  puts "there are #{members.size} members"

  AWS.config(
    :access_key_id => '1ZDRS20XAEP4BZ8WQ182', 
    :secret_access_key => 'cFF877Jx4MVKXLIq0b+YYCYyUStnbYQKHyp7lbFU'
  )
  
  bucket_name = 'assets.civicevolution.org'
  # Get an instance of the S3 interface.
  s3 = AWS::S3.new

  
  members.each do |member|
    #puts "id: #{member.id}, ape_code: #{member.ape_code}"
    
    source_key = "mp/#{member.ape_code}/36/m.jpg"
    target_key = "mp/#{member.ape_code}/small/m.jpg"
    
    if !member.photo_file_name.nil?
      begin
        # Copy the object. and set acl in one action
        s3.buckets[bucket_name].objects[target_key].copy_from(source_key, :acl => :public_read) 
        puts "#{member.id}: Copying file #{source_key} to #{target_key}: http://s3.amazonaws.com/assets.civicevolution.org/mp/#{member.ape_code}/small/m.jpg"		
      rescue Exception => e
        puts "Error for member #{member.id}, #{member.ape_code}"
      end
    else
      puts "Skipping member #{member.id}"
    end

  end
    
end
