class PlanController < ApplicationController
  def index

@member = Member.find(1)


    logger.debug "\n\n******************************************\nStart plan/index\n"
    begin
      @team = Team.includes(:questions => [:talking_points, :comments]).find(params[:id])
      @team.get_talking_point_ratings(@member.id)
    rescue
      render :template => 'team/proposal_not_found', :layout=>'welcome'
      return
    end
    
    #@questions = @team.questions
    
    render :index, :layout=> false
    
    logger.debug "\n\nShow plan/index\n******************************************\n"
    logger.flush
    #logger.auto_flushing = 1
  end
  
  protected
  
  def authorize
    logger.debug "plan.authorize"
  end
  
  def add_member_data
    logger.debug "plan.add_member_data"
  end

end
