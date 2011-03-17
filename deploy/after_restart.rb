begin
  app = Rails.root.to_s.match(/\/data\/(\w+)/)[1]
  if app == 'app_2029'
    sudo "monit restart notify_d_#{app}"
    sudo "monit restart delayed_job_#{app}"
    sudo "monit restart mongrel -g #{app}"
  end
rescue
  
end