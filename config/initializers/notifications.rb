ActiveSupport::Notifications.subscribe('tracking') do |name, start, finish, id, payload|  
  TrackingNotifications.process_event( payload)
end