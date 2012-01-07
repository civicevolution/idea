begin
  app = release_path.to_s.match(/\/data\/(\w+)/)[1]
  sudo "chmod 0666 /var/log/engineyard/apps/#{app}/*"
rescue Exception => e
  run "echo 'deploy/before_restart.rb error: #{e.message}"
end