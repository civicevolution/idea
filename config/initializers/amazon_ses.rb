require 'aws/ses'

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id => '1ZDRS20XAEP4BZ8WQ182',
  :secret_access_key => 'cFF877Jx4MVKXLIq0b+YYCYyUStnbYQKHyp7lbFU'