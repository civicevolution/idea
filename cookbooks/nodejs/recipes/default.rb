#
# Cookbook Name:: nodejs
# Recipe:: default
#

if ['solo','app_master'].include?(node[:instance_role])

  nodejs_file = "node-v0.4.12.tar.gz"
  nodejs_dir = "node-v0.4.12"
  nodejs_url = "http://nodejs.org/dist/#{nodejs_file}"
  
  ey_cloud_report "nodejs" do
    message "configuring nodejs (#{nodejs_dir})"
  end

  directory "/data/nodejs" do
    owner 'root'
    group 'root'
    mode 0755
    recursive true
  end
  
  # download nodejs 
  remote_file "/data/nodejs/#{nodejs_file}" do
    source "#{nodejs_url}"
    owner 'root'
    group 'root'
    mode 0644
    backup 0
    not_if { FileTest.exists?("/data/nodejs/#{nodejs_file}") }
  end
  execute "unarchive nodejs" do
    # remove the node EY installs
    command "rm -R /opt/node"
    
    command "cd /data/nodejs && tar zxf #{nodejs_file} && sync"
    not_if { FileTest.directory?("/data/nodejs/#{nodejs_dir}") }
  end
  
  # compile nodejs
  execute "configure nodejs" do
    command "cd /data/nodejs/#{nodejs_dir} && ./configure"
    not_if { FileTest.exists?("/data/nodejs/#{nodejs_dir}/node") }
  end
  execute "build nodejs" do
    command "cd /data/nodejs/#{nodejs_dir} && make"
    not_if { FileTest.exists?("/data/nodejs/#{nodejs_dir}/node") }
  end
  execute "install nodejs" do
    command "cd /data/nodejs/#{nodejs_dir} && make install"
    # move old version and create a sym link
    command "mv /opt/node /opt/node_ey"
    command "ln -sfv /usr/local /opt/node"
    
    not_if { FileTest.exists?("/usr/local/bin/node") }
  end

  # install npm
  ey_cloud_report "npm" do
    message "configuring npm"
  end

  # download npm
  execute "download and install npm" do
    command "curl http://npmjs.org/install.sh | clean=no sh"
    not_if { FileTest.exists?("/usr/local/bin/npm") }
  end

#  # add to monit
#  case node[:instance_role]
#    when "solo", "app_master"
#      node[:applications].each do |app_name,data|
#
#        template "/etc/monit.d/notify_d.#{app_name}.monitrc" do
#          source "notify_d.monitrc.erb"
#          owner "root"
#          group "root"
#          mode 0644
#          variables({
#            :app_name => app_name,
#            :user => node[:owner_name],
#            :group => node[:owner_name],
#            :worker_name => "notify_d_#{app_name}"
#          })
#        end
#
#      end
#  end
#  
#  # reload monit
#  case node[:instance_role]
#    when "solo", "app_master"
#      execute "monit reload" do
#        action :run
#      end
#  end


end