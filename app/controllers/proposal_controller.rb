class ProposalController < ApplicationController
  skip_before_filter :authorize, :only => [ :print, :vote ]
    
  def print
    @team = Team.find(params[:team_id])
    @endorsements = Endorsement.includes(:member).order('id ASC').all(:conditions=>['team_id=?',@team.id])
    
    render :template=>'proposal/print', :locals=>{:team => @team}, :layout => 'print'
  end
  
  def vote
    # get the list of init ideas
    @init_teams = Team.proposal_stats(params[:_initiative_id])
    
  end
  
  def vote_save
    votes = {}
    params.each_pair do |key,value|
      if key.match(/^vote_\d+/) && value.to_i > 0
        votes[ key.match(/\d+/)[0].to_i] = value.to_i
      end
    end

    ProposalVote.save_votes(params[:_initiative_id], @member.id, votes)
  end
  
end