# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true
config.action_mailer.perform_deliveries = true
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_charset = "utf-8"

RES_BASE='civic_dev'

#Recaptcha constants for *.1civicevolution.org
#RCC_PUB='6Le027wSAAAAABJKdXtEfpJb7-T3ybjUC3tpuCnn'
#RCC_PRIV='6Le027wSAAAAAPaLO5Tv3fhU-s7slUOSiwOHXwYI'

#Recaptcha constants for *.civicevolution.org
#RCC_PUB='6Lez27wSAAAAAO63HjGN8VutXx3zydGRc8jBUnGY'
#RCC_PRIV='6Lez27wSAAAAAHHJ0f5W_GR9JX6jGqOJX112SuvV'

##Recaptcha constants for *.civicevolution.net
#RCC_PUB='6Le4sL0SAAAAAH7uDZDOnkwRHKHCNqAbylQrGMu_'
#RCC_PRIV='6Le4sL0SAAAAAHjasKBj7ttAoNRQYjI3PGZm0xq-'

# Google analytics constants
GOOGLE_ANALYTICS_ACCOUNT = "UA-19050643-1"
GOOGLE_ANALYTICS_DOMAIN = ".civicevolution.net"

config.action_mailer.smtp_settings = {
  :enable_starttls_auto => true,
  :address => "smtp.civicevolution.org",
  :domain => 'civicevolution.org',
  :port => 25,
  :user_name => "ce-prod", 
  :password	=> "cece",
  :authentication => :plain, 
}


#config.action_mailer.smtp_settings = {
#    :enable_starttls_auto => true,
#    :address        => 'smtp.gmail.com',
#    :port           => 587,
#    :domain         => 'civicevolution.org',
#    :authentication => :plain,
#    :user_name      => 'civicevolution@gmail.com',
#    :password       => '54645464'
#}


