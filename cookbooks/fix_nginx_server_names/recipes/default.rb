#
# Cookbook Name:: fix_nginx_server_names
# Recipe:: default
#

case node[:instance_role]
  when "solo", "app_master", "app"
    node[:applications].each do |app_name,data|
      filepath = "/data/nginx/servers/#{app_name}.conf"
      config = IO.read(filepath)
      
      #ruby 1.8 doesn't support lookahead, so I'll just look for default
      
      is_default_server = config.match(/^\s*server_name.*\sdefault/i) ? true : false

      if is_default_server
        lines = config.split(/\n/)
        
        ruby_block "remove default from nginx server.conf server_name and set default_server in listen directive" do
          block do
            File.open(filepath, "w") do |file|
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
      end
    end # node.each
    
    # now I want to restart nginx
    # Restart nginx

    execute "Restart nginx" do
      command %Q{
        /etc/init.d/nginx restart
      }
    end


end # case
