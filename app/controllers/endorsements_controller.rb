class EndorsementsController < ApplicationController
  
# endorsements/:team_id/add
# endorsements/:team_id/delete
# endorsements/:team_id/update
  
  def add_endorsement
    endorsement = Endorsement.find_or_create_by_member_id_and_team_id(@member.id,params[:team_id])
    endorsement.text = params[:text]
    respond_to do |format|
      if endorsement.save
        format.html { redirect_to plan_path(params[:team_id]) }
      else
        flash[:endorsement_error] = endorsement.errors
        format.html { redirect_to plan_path(params[:team_id]) }
      end
    end
  end
  
  def delete
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id,params[:team_id])
    endorsement.destroy unless endorsement.nil?
    respond_to do |format|
      format.html { redirect_to plan_path(params[:team_id]) }
    end
  end
  
  def edit
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id,params[:team_id])
    respond_to do |format|
      format.html { render 'endorsements/edit', :locals => {:endorsement=>endorsement}, :layout => 'plan' }
    end
  end

  def update
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id,params[:team_id])
    endorsement.text = params[:text]
    respond_to do |format|
      if endorsement.save
        format.html { redirect_to plan_path(params[:team_id]) }
      else
        flash[:endorsement_error] = endorsement.errors
        format.html { redirect_to plan_path(params[:team_id]) }
      end
    end

  end
  
end