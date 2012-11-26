class ProposalController < ApplicationController
  skip_before_filter :authorize, :only => [ :print, :vote, :list ]
    
  def print
    @team = Team.includes(:idea, :question_ideas => :themes).find(params[:team_id])
    @endorsements = Endorsement.includes(:member).order('id ASC').all(:conditions=>['team_id=?',@team.id])
    
    render :template=>'proposal/print', :locals=>{:team => @team}, :layout => 'print'
  end
  
  def vote
    # get the list of init ideas
    @init_teams = Team.proposal_stats(params[:_initiative_id])
    
  end
  
  def vote_save
    votes = {}
    
    begin
      params.each_pair do |key,value|
        if key.match(/^vote_\d+/) && value.to_i > 0
          votes[ key.match(/\d+/)[0].to_i] = value.to_i
        end
      end
      
      saved, err_msgs = ProposalVote.save_votes(params[:_initiative_id], @member.id, votes)
    rescue
      saved = false
    end

    if saved
      respond_to do |format|
        #format.html { render :summary, :layout => 'plan' }
        format.js { render :template => 'proposal/vote_saved', :locals=>{:status=>'saved'} }
      end
      
    else
      respond_to do |format|
        #format.html { render :summary, :layout => 'plan' }
        format.js { render :template => 'proposal/vote_saved', :locals=>{:status=>'failed', :err_msgs => err_msgs} }
      end
      
    end
    
    
  end
  
  
  def list
    if params[:_initiative_id].between?(1,2)
      init = [1,2]
    else
      init = params[:_initiative_id]
    end
    @team_stats = Team.includes(:proposal_stats).where(:initiative_id => init, :archived=>false).order('initiative_id DESC, title ASC')
    respond_to do |format|
      format.html{ render template: 'proposal/list', layout: 'plan'}
    end
  end    
  
  
end