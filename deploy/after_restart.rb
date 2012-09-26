begin
  app = release_path.to_s.match(/\/data\/(\w+)/)[1]
  if app == 'idea'
     sudo 'echo "sleep 180 && sudo monit restart notify_d_idea" | at now'
     sudo 'echo "sleep 360 && sudo monit restart delayed_job_idea" | at now'
  end
rescue Exception => e
  run "echo 'deploy/after_restart.rb error: #{e.message}"
end
