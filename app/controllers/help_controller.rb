class HelpController < ApplicationController
  layout "plan", :except => [:something_else]
  skip_before_filter :authorize
   
  def visual_help
    
  end

end

