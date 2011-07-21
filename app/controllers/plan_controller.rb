class PlanController < ApplicationController
  def index

#@member = Member.find(1)


    logger.debug "\n\n******************************************\nStart plan/index\n"
    begin
      @team = Team.includes(:questions).find(params[:id])
      @team.get_talking_point_ratings(@member.id)
      @team['org_member'] = Member.find_by_id(@team.org_id)
    rescue
      render :template => 'team/proposal_not_found', :layout=>'welcome'
      return
    end
    
    #@questions = @team.questions
    
    render :index #, :layout=> false
    
    logger.debug "\n\nShow plan/index\n******************************************\n"
    logger.flush
    #logger.auto_flushing = 1
  end

end
