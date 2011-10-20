require 'development_mail_interceptor'
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) unless Rails.env.production?
#ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) unless Rails.env.production? && !Rails.root.to_s.match(/app_2029/).nil?