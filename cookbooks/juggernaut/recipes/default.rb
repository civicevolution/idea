#
# Cookbook Name:: juggernaut
# Recipe:: default
#
# Install and start Juggernaut server
#
# IMPORTANT: This has to run AFTER node.js is installed


# I want to get the address of the DB MASTER from /etc/chef/dna.json
# chef_file = '/etc/chef/dna.json'
# chef_config = JSON.parse(File.read(chef_file))
# chef_config['db_host']
# => "ec2-50-18-101-127.us-west-1.compute.amazonaws.com"

pid_file = '/var/run/juggernaut.pid'
chef_file = '/etc/chef/dna.json'
chef_config = JSON.parse(File.read(chef_file))
redis_host = chef_config['db_host']
redis_port = 6379
redis_user = 'brian'
redis_pwd = 'pwd'

master_app_server_host = chef_config['master_app_server']['public_ip']
node_js_port = 8080

#redis_host = 'http://brian:123@ec2-50-18-101-127.us-west-1.compute.amazonaws.com:6379'

if ['app','app_master','solo'].include?(node[:instance_role])
  install_dir     = "/usr/local/bin"

  ey_cloud_report "juggernaut" do
    message "Setting up juggernaut server"
  end

  execute "npm install juggernaut" do
    command "npm install -g juggernaut"
    not_if { FileTest.exists?("#{install_dir}/juggernaut") }
  end

  execute "start juggernaut daemon" do
    command "/sbin/start-stop-daemon --start --background --exec #{install_dir}/juggernaut --chuid root:root"
#    not_if { FileTest.exists?("#{install_dir}/juggernaut") }
  end

# install init.d
  case node[:instance_role]
    when "solo", "app_master"
      template "/etc/init.d/juggernaut" do
        source "juggernaut.init.d.erb"
        owner "root"
        group "root"
        mode 0755
        variables({
          :pid_file => pid_file,
          :redis_host => redis_host,
          :redis_port => redis_port,
          :redis_user => redis_user,
          :redis_pwd => redis_pwd
        })  
      end
  end



  # add to monit
  case node[:instance_role]
    when "solo", "app_master"
      template "/etc/monit.d/juggernaut.monitrc" do
        source "juggernaut.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :pid_file => pid_file
        })
      end
  end
  
  # this restart also affects daemons (monitrc for notify and delayed_job)
  # reload monit
  case node[:instance_role]
    when "solo", "app_master"
      execute "monit reload" do
        action :run
      end
  end


  # mod haproxy.cfg to send node requests on port 80 to nodejs port
  # Find next line(s) that starts with server
  # and retrieve the host
  # create a fragment from the template, with the host in it
  # insert the fragment right after the commented out server line
  
  case node[:instance_role]
    when "solo", "app_master"
      filepath_haproxy_frag = "/etc/haproxy.frag.cfg"
      filepath_haproxy = "/etc/haproxy.cfg"
      
      # Don't process haproxy.cfg if it already has backend nodejs_server
      haproxy = IO.read(filepath_haproxy)
      
      if !haproxy.match(/nodejs_server/)
        Chef::Log.info "Yes, I need to process haproxy.cfg"
        # first create the fragement I will need
        # then read it into a variable to insert into the actual haproxy.cfg
        template filepath_haproxy_frag do
          source "haproxy.cfg.frag.erb"
          owner "root"
          group "root"
          mode 0644
          variables({
            :master_app_server_host => master_app_server_host,
            :node_js_port => node_js_port
          })  
        end
      
        ruby_block "insert the nodejs compliant front end into haproxy" do
          block do
            haproxy_frag = IO.read(filepath_haproxy_frag)
            File.open(filepath_haproxy, "w") do |file|
              haproxy.split(/\n/).each do |line|
                if line.match(/listen\s*cluster\s*:80/i)
                  file.puts "# #{line}"
                  file.puts "###################\n# Custom code inserted by Chef to route realtime to nodejs\n"
                  file.puts haproxy_frag
                else
                  file.puts line
                end
              end
            end # end file
          end # block
          action :create
        end # ruby_block
      
        execute "Delete the cfg frag" do
          command "rm #{filepath_haproxy_frag}"
        end  
      
        execute "Restart haproxy" do
          command %Q{
            /etc/init.d/haproxy restart
          }
        end  
      end
  end






end

