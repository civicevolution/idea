ActiveSupport::Notifications.subscribe('tracking') do |name, start, finish, id, payload|  
  TrackingNotifications.delay.process_event( payload)
end