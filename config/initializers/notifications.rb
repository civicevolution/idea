ActiveSupport::Notifications.subscribe('tracking') do |name, start, finish, id, payload|  
  if Rails.env == 'production'
    TrackingNotifications.delay.process_event( payload)
  else # don't delay in DEV to make debugging easier
    TrackingNotifications.process_event( payload)
  end
end