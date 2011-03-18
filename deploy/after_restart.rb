begin
  app = release_path.to_s.match(/\/data\/(\w+)/)[1]
  if app == 'app_2029'
    sudo "monit restart notify_d_#{app}"
    sudo "monit restart delayed_job_#{app}"
    sudo "monit restart mongrel -g #{app}"
  end
rescue Exception => e
  run "echo 'deploy/after_restart.rb error: #{e.message}"
end