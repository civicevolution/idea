class HelpController < ApplicationController
  layout "plan", :except => [:something_else]
  skip_before_filter :authorize
   
  def visual_help
    
  end

  def help_endorse_proposal
    
  end
  
  def help_develop_proposal
    
  end
  
end

