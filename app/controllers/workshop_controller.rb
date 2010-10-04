class WorkshopController < ApplicationController
  def proposal_form
    # if there is an id param - get the data - if they are the member
    if params[:id]
      form = Form.find_by_id(params[:id])
      logger.debug "form.member_id: #{form.member_id}, sess: #{session[:member_id]}"
      
      if form.member_id == session[:member_id].to_i
        logger.debug "Get the data for this form"
        @form_data = form.get_data
      else
        render :text => "You are not authorized to view this form, please contact us at support@civicevolution.org if you believe this is an error", :layout=>'welcome'
        return
      end
      
    end
    @form_data = {} if @form_data.nil?
    logger.debug "form_data: #{@form_data}"
    render :action => "proposal_form", :layout => 'welcome'
  end

  def submit_workshop_idea
    logger.debug "save the workshop form"
    form_id = Form.save_form(params[:workshop_proposal], session[:member_id])
    saved = true
    respond_to do |format|
      if saved
        format.json { render :text => [ { :form_id=> form_id, :status=>'ok'} ].to_json }
      else
        format.json { render :text => [@form.errors].to_json, :status => 500 }
      end
    end
  end
  
  def preview_workshop_proposal_form
    if params[:id]
      form = Form.find_by_id(params[:id])
      logger.debug "form.member_id: #{form.member_id}, sess: #{session[:member_id]}"
      
      if form.member_id == session[:member_id].to_i
        logger.debug "Get the data for this form"
        @form_data = form.get_data
      else
        render :text => "You are not authorized to view this form, please contact us at support@civicevolution.org if you believe this is an error", :layout=>'welcome'
        return
      end
      
    end
    @form_data = {} if @form_data.nil?
    logger.debug "form_data: #{@form_data}"
    render :action => "preview_workshop_proposal_form", :layout => 'welcome'
    
  end
  
  def submit_workshop_proposal_form
    if params[:id]
      form = Form.find_by_id(params[:id])
      logger.debug "form.member_id: #{form.member_id}, sess: #{session[:member_id]}"
      
      if form.member_id == session[:member_id].to_i
        logger.debug "Get the data for this form"
        @form_data = form.get_data
      else
        render :text => "You are not authorized to view this form, please contact us at support@civicevolution.org if you believe this is an error", :layout=>'welcome'
        return
      end
      
    end
    @form_data = {} if @form_data.nil?
    member = Member.find(session[:member_id])
    
    @host = request.env["HTTP_HOST"]
    FormMailer.deliver_forward_submitted_form(member, @form_data, @host )
    FormMailer.deliver_submitted_form_receipt(member, @form_data )
    render :action => "submit_workshop_proposal_form", :layout => 'welcome'
    
  end
  
  def review_workshop_proposal
    form = Form.find_by_id(params[:id])
    @form_data = form.get_data
    render :action => "review_workshop_proposal", :layout => 'welcome'
  end
  
  def workshop_format
    
  end

  def approve_proposal
  end

protected
  
end
