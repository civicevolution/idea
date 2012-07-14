desc "Find all the emails that were sent to team_members by Admin"
task :create_attr_accessible => :environment do
  puts "Generate attr_accessible statements for each model"
  
  in_table = false
  
  rec_ctr = 1;
  sent_date = nil
  filepath = "#{Rails.root.to_s}/db/schema.rb"
  line = nil
  table_name = nil
  columns = nil
  
  begin
    File.open(filepath) do |file|
      file.each_line do |line|
        if line.match(/create_table/)
          in_table = true
          table_name = line.match(/"([^"]*)"/)[1]
          columns = []
        elsif line.match(/\A\s*end\s*\z/)
          if in_table
            
            puts table_name
            puts "\nattr_accessible :#{columns.join(', :')}\n\n\n\n\n\n\n"
            in_table = false
            table_name = nil
            columns = nil
          end
        elsif in_table && line.match(/"([^"]*)"/)
          col_name = line.match(/"([^"]*)"/)[1]
          if col_name != 'created_at' && col_name != 'updated_at'
            columns.push col_name
          end
        end
      end
    end
  end
  
end
