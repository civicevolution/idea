class DevelopmentMailInterceptor  
  def self.delivering_email(message)  
    if message.to[0] != 'support@civicevolution.org'
      message.subject = "[#{message.to}] #{message.subject}"  
      message.to = "dev_test_email@civicevolution.org"  
    end
  end  
end