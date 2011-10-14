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

end