G3::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  
  RES_BASE='civic_dev'  
  
  # Google analytics constants
  GOOGLE_ANALYTICS_ACCOUNT = "UA-19050643-1"
  GOOGLE_ANALYTICS_DOMAIN = ".civicevolution.net"

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  
  # disable sending through Amazon SES
  #config.action_mailer.delivery_method = :ses
  
  config.action_mailer.logger = ActiveSupport::BufferedLogger.new( "#{Rails.root}/log/mail.sent.log" )
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "smtp.sendgrid.net",
    :domain => 'civicevolution.org',
    :port => 587,
    :user_name => "civicevolution2SFO", 
    :password	=> "gayjorge2011CANYON",
    :authentication => :plain, 
  }
  
  Paperclip.options[:command_path] = "/opt/local/bin"
  
  REDIS_CLIENT = Redis.new(:host => 'localhost', :port => 6379)	
  
  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger.const_get(
    ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'DEBUG'
  )
  
end

