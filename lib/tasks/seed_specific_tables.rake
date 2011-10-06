namespace :seed_specific_tables do

  desc "Seed participation_event_descriptions"
  task :participation_event_descriptions => :environment do 
    puts "Do Seed participation_event_descriptions"
    yml = YAML.load_file "#{Rails.root}/config/participation_event_descriptions.yaml"
  
    yml.each_pair { |key, value|
      rec = value
      # create a record
      event = ParticipationEventDetail.new :description => rec['description']
      event.id = rec['id']
      event.save   
    }
    puts "End Seed participation_event_descriptions"
  end
  
end