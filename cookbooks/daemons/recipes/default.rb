#
# Cookbook Name:: delayed_job
# Recipe:: default
#

case node[:instance_role]
  when "solo", "app_master"
    node[:applications].each do |app_name,data|
  
      template "/etc/monit.d/notify_d.#{app_name}.monitrc" do
        source "notify_d.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :group => node[:owner_name],
          :worker_name => "notify_d_#{app_name}"
        })
      end

      template "/etc/monit.d/delayed_job.#{app_name}.monitrc" do
        source "delayed_job.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :group => node[:owner_name],
          :worker_name => "delayed_job_#{app_name}"
        })
      end
      
      
    end
    execute "monit reload" do
      action :run
    end
end