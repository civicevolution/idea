begin
  app = release_path.to_s.match(/\/data\/(\w+)/)[1]
  if app == 'app_2029' || app == 'tp'
     #sudo "sleep 180; monit restart notify_d_#{app}"
     sudo 'echo "sleep 180 && sudo monit restart notify_d_tp" | at now'
     #sudo "sleep 300; monit restart delayed_job_#{app}"
     sudo 'echo "sleep 360 && sudo monit restart delayed_job_tp" | at now'
  end
rescue Exception => e
  run "echo 'deploy/after_restart.rb error: #{e.message}"
end
