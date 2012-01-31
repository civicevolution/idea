class HelpController < ApplicationController
  layout "plan", :except => [:something_else]
  skip_before_filter :authorize
   
  def visual_help
    render :template=>'help/visual_help', :layout => 'plan'
    
  end

  def help_endorse_proposal

  end
  
  def help_develop_proposal
    
  end

  def help_answer_question
    
  end
  
  def help_curate_show_path
    
  end
  
  
end

