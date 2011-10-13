#      filepath = "/data/nginx/servers/#{app_name}.conf"
      filepath = "#{Rails.root.to_s}/script/haproxy.cfg"
      config = IO.readlines(filepath,'').to_s

      #ruby 1.8 doesn't support lookahead, so I'll just look for default
      
      is_default_server = config.match(/^\s*server_name.*\sdefault/i) ? true : false

      if is_default_server
        lines = config.split(/\n/)  # 93 in ruby 1.8.7, 1 in 1.9.2
        
        
        ruby_block "remove default from nginx server.conf server_name and set default_server in listen directive" do
          block do
            File.open(filepath, "w") do |file|
              # lines.each{|line| puts line}
              lines.each do |line|
                if line.match(/^\s*server_name.*\sdefault/i)
                  file.puts line.gsub(/\sdefault/i, ' ')
                elsif line.match(/^\s*listen/)
                  file.puts line.gsub(/;/,' default_server;') # later versions require default_server
                else
                  file.puts line
                end
              end
            end # end file
          end # block
          action :create
        end # ruby_block
        
#


filepath = "#{Rails.root.to_s}/haproxy.cfg.orig"    # PROD
filepath = "#{Rails.root.to_s}/script/haproxy.cfg"  # west/dev
config = IO.readlines(filepath,'').to_s
lines = config.split(/\n/)
lines.size 
lines.each{ |line| puts "XXXX#{line}\n\n"}       

93 for PROD
1 for DEV


rvm pkg install readline
