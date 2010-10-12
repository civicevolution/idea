# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

RES_BASE='civic'

#RCC_PUB='6Lez27wSAAAAAO63HjGN8VutXx3zydGRc8jBUnGY'
#RCC_PRIV='6Lez27wSAAAAAHHJ0f5W_GR9JX6jGqOJX112SuvV'

# Google analytics constants
GOOGLE_ANALYTICS_ACCOUNT = "UA-19051771-1"
GOOGLE_ANALYTICS_DOMAIN = ".civicevolution.org"

# Disable delivery errors, bad email addresses will be ignored
config.action_mailer.raise_delivery_errors = false
#config.action_mailer.raise_delivery_errors = true
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






# Enable threaded mode
# config.threadsafe!