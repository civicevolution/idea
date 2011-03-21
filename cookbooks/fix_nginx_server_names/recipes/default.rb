#
# Cookbook Name:: fix_nginx_server_names
# Recipe:: default
#

case node[:instance_role]
  when "solo", "app_master", "app"
    node[:applications].each do |app_name,data|
  
      filepath = "/data/nginx/servers/#{app_name}.conf"

      config = IO.readlines(filepath,'').to_s
      lines = config.split(/\n/)

      ruby_block "remove commas from nginx server.conf server_name" do
        block do
          File.open(filepath, "w") do |file|
            lines.each do |line|
              if line.match(/^\s*server_name/)
                file.puts line.gsub(/,/,'')
              elsif line.match(/^\s*listen/) && app_name == 'civic'
                file.puts line.gsub(/;/,' default;') # later versions require default_server
              else
                file.puts line
              end
            end
          end # end file
        end # block
        action :create
      end # ruby_block
    
    end # node.each
    
    # now I want to restart nginx
    # Restart nginx

    execute "Restart nginx" do
      command %Q{
        /etc/init.d/nginx restart
      }
    end


end # case
