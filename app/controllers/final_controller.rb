class FinalController < ApplicationController
  
  def proposal
    @team = Team.find(params[:team_id])
    @endorsements = Endorsement.includes(:member).order('id ASC').all(:conditions=>['team_id=?',@team.id])
    
    render :template=>'final/proposal', :locals=>{:edit_mode => params[:edit]}, :layout => 'plan'
  end
  
  def printer_friendly
    @item_id = params[:id].to_i
    
    @root_item = Item.find(@item_id)
    @team_id = @root_item.team_id

    #logger.debug "Check for team id: #{@team_id}"  
    @team = Team.find_by_id(@team_id)
    if @team.nil?
      render :text => "The team you requested does not exist. Please return to the home page and sign in: http://uos.civicevolution.org"
      return
    end

    #logger.debug "Check for team = private"  
    # if this team is not available, show a message
    if @team.status == 'private'
      render :text => "This team is currently private"
      return
    end
    
    logger.debug "Check for team registration"  

    # does user have access?
    team_member = TeamRegistration.find_by_member_id_and_team_id( session[:member_id] , @team_id)
    if team_member.nil?
      render :text => "You do not have access to this team"
      return
    end
    
    @last_ts = Team.find(@team_id).last_visit( session[:member_id] )
    @members = @team.members 
    @items = @team.items
    @pages = @team.pages
    @questions = @team.questions
    @answers = @team.answers
    @ratings = @team.average_ratings
    @thumbs_ratings = []
    @my_thumbs_ratings = []
    @team_item = @items.detect {|i| i.o_id == @team_id && i.o_type == 4 } 
    @items_par_0_sorted = @items.find_all {|i| i.par_id == @item_id }.sort {|a,b| a.order <=> b.order }
#debugger    
    @lists = @team.lists
    @list_items = @team.list_items
  
    Activity.new(:member_id=>session[:member_id], :team_id=>@team_id, :action=>'team printer_friendly',
      :user_agent=>request.env["HTTP_USER_AGENT"], :cookie=>request.env["HTTP_COOKIE"], :ip=>request.remote_ip).save
    
  end
  
  
  
  
end