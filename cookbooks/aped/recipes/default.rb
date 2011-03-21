#
# Cookbook Name:: aped
# Recipe:: default
#

case node[:instance_role]
  when "solo", "app_master"
    template "/etc/monit.d/aped.monitrc" do
      source "aped.monitrc.erb"
      owner "root"
      group "root"
      mode 0644
    end
    execute "monit reload" do
      action :run
    end
end