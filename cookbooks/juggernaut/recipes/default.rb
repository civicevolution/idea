#
# Cookbook Name:: juggernaut
# Recipe:: default
#
# Install and start Juggernaut server
#
# IMPORTANT: This has to run AFTER node.js is installed

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

end

