source 'https://rubygems.org'

gem 'rails', '3.2.12'

group :development do
  # this is single threaded server & can't do pdf generation
  gem 'thin', '1.4.1'
  #gem 'debugger', '= 1.1.4'
  
  # unicorn can do multiple workers
  gem 'unicorn'
  gem 'debugger'
  
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :production do
  # Use unicorn as the web server
  gem 'unicorn'
	gem 'newrelic_rpm', '>= 3.5.3.25'
end

gem 'eventmachine', '= 0.12.10'
gem "bluecloth"
gem "daemons"
gem "diff-lcs"
gem "differ"
gem "haml"
gem 'sass'
gem 'paperclip'
gem "pg", '= 0.14.0'
gem "recaptcha", :require => "recaptcha/rails"
gem "tzinfo"
gem "uuidtools"
gem "json", '= 1.7.3'
gem 'aws-s3', :require => 'aws/s3'
gem "aws-ses"
gem 'aws-sdk'
gem 'delayed_job_active_record'

gem 'jquery-rails'
gem 'jquery-ui-rails'

gem "airbrake"

gem "juggernaut"

gem "redis"

gem 'rails_autolink'

gem 'actionmailer-callbacks'

gem 'pdfkit'