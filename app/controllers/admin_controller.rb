class AdminController < ApplicationController

  def index
    
    
    
  end
  
  def members
    @members = Member.gen_report(params[:init_id])
  end

  def teams
    @teams = Team.gen_report(params[:init_id])
  end

  def ideas
    @ideas = ProposalIdea.all()
  end

  def team_workspace
    
  end
  
  def team_members
    
  end





  protected
  
    def authorize
      @member = Member.find_by_id(session[:member_id])
      unless @member
        if request.xhr? || params[:post_mode] == 'ajax'
          # send back a simple notice, do not redirect
          m = Member.new
          m.errors.add(:base, 'You must sign in to continue')
          render :text => [m.errors].to_json, :status => 401
          return
        else
          flash[:pre_authorize_uri] = request.request_uri
          flash[:notice] = "Please sign in"
          render :template => 'welcome/must_sign_in', :layout => 'welcome'
          #redirect_to :controller => 'welcome' , :action => 'not_signed_in'
          return
        end
      end
      
      if @member.email != 'brian@civicevolution.org'
        if request.xhr? || params[:post_mode] == 'ajax'
          # send back a simple notice, do not redirect
          m = Member.new
          m.errors.add(:base, 'You are not recognized as a system administrator')
          render :text => [m.errors].to_json, :status => 401
          return
        else
          flash[:pre_authorize_uri] = request.request_uri
          render :action => 'not_recognized_admin'
          return
        end
      end
      
    end

end