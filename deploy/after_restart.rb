begin
  app = release_path.to_s.match(/\/data\/(\w+)/)[1]
  if app == 'tp'
     sudo 'echo "sleep 180 && sudo monit restart notify_d_tp" | at now'
     sudo 'echo "sleep 360 && sudo monit restart delayed_job_tp" | at now'
  end
rescue Exception => e
  run "echo 'deploy/after_restart.rb error: #{e.message}"
end
