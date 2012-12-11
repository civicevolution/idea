class EndorsementsController < ApplicationController
  
# endorsements/:team_id/add
# endorsements/:team_id/delete
# endorsements/:team_id/update
  
  def add_endorsement
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id,params[:team_id])
    endorsement = Endorsement.new :member_id => @member.id, :team_id => params[:team_id] if endorsement.nil?
    endorsement.text = params[:text]
    endorsement.member = @member
    
    respond_to do |format|
      if endorsement.save
        format.js { render 'endorsements/endorsement_for_proposal', locals: { endorsement: endorsement} }
        format.html { redirect_to plan_path(params[:team_id], endorsements: true) }
      else
        format.js { render 'endorsements/endorsement_for_proposal_errors', locals: { endorsement: endorsement} }
        flash[:endorsement_error] = endorsement.errors
        format.html { redirect_to plan_path(params[:team_id]) }
      end
    end
  end
  
  def delete
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id,params[:team_id])
    if !endorsement.nil?
      endorsement_id = endorsement.id  
      endorsement.member = @member
      endorsement.destroy
    else
      endorsement_id = 0
    end
    respond_to do |format|
      format.js { render 'endorsements/delete_endorsement_for_proposal', locals: { endorsement_id: endorsement_id} }
      format.html { redirect_to plan_path(params[:team_id], endorsements: true) }
    end
  end
  
  def edit
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id,params[:team_id])
    endorsement.member = @member
    respond_to do |format|
      format.html { render 'endorsements/edit', :locals => {:endorsement=>endorsement}, :layout => 'plan' }
    end
  end

  def update
    endorsement = Endorsement.find_by_member_id_and_team_id(@member.id,params[:team_id])
    endorsement.text = params[:text]
    endorsement.member = @member
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