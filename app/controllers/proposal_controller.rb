class ProposalController < ApplicationController
  skip_before_filter :authorize, :only => [ :print ]
    
  def print
    @team = Team.find(params[:team_id])
    @endorsements = Endorsement.includes(:member).order('id ASC').all(:conditions=>['team_id=?',@team.id])
    
    render :template=>'proposal/print', :locals=>{:team => @team}, :layout => 'print'
  end
  
end