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
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin


  RES_BASE='civic_dev'  
  
  # Google analytics constants
  GOOGLE_ANALYTICS_ACCOUNT = "UA-19050643-1"
  GOOGLE_ANALYTICS_DOMAIN = ".civicevolution.net"

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_charset = "utf-8"

  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "smtp.civicevolution.org",
    :domain => 'civicevolution.org',
    :port => 25,
    :user_name => "ce-prod", 
    :password	=> "cece",
    :authentication => :plain, 
  }
  
  Paperclip.options[:command_path] = "/opt/local/bin"
  
  
end

