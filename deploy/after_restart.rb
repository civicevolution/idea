begin
  app = release_path.to_s.match(/\/data\/(\w+)/)[1]
  logger.warn "after_restart.rb for app: #{app}"
  if app == 'idea' || app == 'tp'
     sudo 'echo "sleep 180 && sudo monit restart notify_d_#{app}" | at now'
     sudo 'echo "sleep 360 && sudo monit restart delayed_job_#{app}" | at now'
  end
rescue Exception => e
  run "echo 'deploy/after_restart.rb error: #{e.message}"
end
