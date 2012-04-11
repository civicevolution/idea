class CeLiveController < ApplicationController
  layout "ce_live"
  prepend_before_filter :identify_node, :except => [ :live_home, :sign_in_form, :sign_in_post]
  skip_before_filter :authorize , :only => [:live_home, :sign_in_form ]
  skip_before_filter :add_member_data# , :except => [ :logo, :rss ]

  
  
  def live_home
    # default page for CivicEvolution Live
    render :template=>'welcome/index.html', :layout=>'civicevolution'
  end
  
  def auto_mode
    case @live_node.role
      when 'coord'
        redirect_to live_coordinator_path(params[:event_id])
        
      when 'theme'
        redirect_to live_themer_path(params[:event_id])

      when 'scribe'
        redirect_to live_table_path(params[:event_id])
        
    end
    
  end
  
  def coordinator    
    
    @live_node = LiveNode.find_by_live_event_id_and_password_and_username(params[:event_id],'coordinator','coordinator')
    session[:live_node_id] = @live_node.id
    @page_title = "Coordinator's admin page"
    
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'coord'
    @event = LiveEvent.find( params[:event_id])
    @event_sessions = LiveSession.where(:live_event_id => params[:event_id])
    @event_nodes = LiveNode.where(:live_event_id => params[:event_id])
    @channels = ["_auth_event_#{params[:event_id]}", "_auth_event_#{params[:event_id]}_theme"]
    session[:coord_chat_channel] = "_auth_event_#{params[:event_id]}_theme"
    authorize_juggernaut_channels(request.session_options[:id], @channels )

    render :template => 'ce_live/coordinator', :layout => 'ce_live', :locals=>{ :title=>'Cordinator page for CivicEvolution Live', :role=>'Coordinator'}
  end
  
  def themer         
    @session = LiveSession.find_by_id(params[:session_id])
    @live_node = LiveNode.find_by_live_event_id_and_password_and_username(@session.live_event_id,'themer','themer')
    session[:live_node_id] = @live_node.id
    @page_title = "Theme for: #{@session.name}"
    
    @live_talking_points = LiveTalkingPoint.where(:live_session_id => @session.id).order('id ASC')
    @live_theming_session = LiveThemingSession.where(:live_session_id => @session.id, :themer_id => @live_node.id)
    @live_themes_unordered = LiveTheme.where(:live_session_id => @session.id, :themer_id => @live_node.id)
    
    # i need to put the live_themes in the order according to @live_theming_session.theme_group_ids
    @live_themes = []
    @live_theming_session[0].theme_group_ids.split(',').each do |id|
      @live_themes.push @live_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
    end
    
    @live_themes.compact!

    themed_tp_ids = []
    @live_themes.each do |theme|
		  if theme.id.to_i > 0
  			tp_ids = theme.live_talking_point_ids
  			tp_ids = tp_ids.nil? ? [] : tp_ids.split(/[^\d]+/).map{|i| i.to_i}
  			themed_tp_ids += tp_ids
  			theme[:talking_points] = @live_talking_points.select{ |tp| tp_ids.include?(tp.id) }
  		end
		end

    if !@live_theming_session.empty?
  		dont_fit_tp_ids = @live_theming_session[0].unthemed_ids.nil? ? [] : @live_theming_session[0].unthemed_ids.split(/[^\d]+/).map{|i| i.to_i}
  		themed_tp_ids += dont_fit_tp_ids
      @dont_fit_tp = @live_talking_points.select{ |tp| dont_fit_tp_ids.include?(tp.id) }
    end
    
    @live_talking_points = @live_talking_points.reject{ |tp| themed_tp_ids.include?(tp.id) }
    
    
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'theme'
    @channels = ["_auth_event_#{params[:event_id]}", "_auth_event_#{params[:event_id]}_theme", "_auth_event_#{params[:event_id]}_theme_#{@live_node.id}"]
    session[:table_chat_channel] = "_auth_event_#{params[:event_id]}_theme_#{@live_node.id}"
    session[:coord_chat_channel] = "_auth_event_#{params[:event_id]}_theme"
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    render :template => 'ce_live/themer', :layout => 'ce_live', :locals=>{ :title=>'Theming page for CivicEvolution Live', :role=>'Themer'}
  end
  
  def table   
    
    @session = LiveSession.find_by_id(params[:session_id])
    @live_node = LiveNode.find_by_live_event_id_and_password_and_username(@session.live_event_id,'scribe4','scribe4')
    session[:live_node_id] = @live_node.id
    @page_title = "Topic: #{@session.name}"
    
    @live_talking_points = LiveTalkingPoint.where(:live_session_id => @session.id, :group_id => @live_node.id).order('id ASC')

    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'scribe'
    @channels = ["_auth_event_#{params[:event_id]}", "_auth_event_#{params[:event_id]}_theme_#{@live_node.parent_id}"]
    session[:table_chat_channel] = "_auth_event_#{params[:event_id]}_theme_#{@live_node.parent_id}"
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    render :template => 'ce_live/table', :layout => 'ce_live', :locals=>{ :title=>'Scribe page for CivicEvolution Live', :role=>'Scribe'}
  end

  def prioritize   
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'scribe'
    @channels = ["_auth_event_#{params[:event_id]}", "_auth_event_#{params[:event_id]}_theme_#{@live_node.parent_id}"]
    session[:table_chat_channel] = "_auth_event_#{params[:event_id]}_theme_#{@live_node.parent_id}"
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    render :template => 'ce_live/prioritize', :layout => 'ce_live', :locals=>{ :title=>'Prioritization page for CivicEvolution Live', :role=>'Scribe'}
  end
    
  def ltp_to_jug
    ltp = LiveTalkingPoint.find(params[:id])
    Juggernaut.publish(params[:ch], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
    render :text => "On juggernaut on channel; #{params[:ch]}, sent LiveTalkingPoint: #{ltp.inspect}", :content_type => 'text/plain'
  end

  def authorize_juggernaut_channels(session_id, channels )
    # read all the channels for this session_id and clear them
    old_channels = REDIS_CLIENT.HGET "session_id_channels", session_id
    if old_channels
      JSON.parse(old_channels).each do |channel|
        REDIS_CLIENT.SREM channel,session_id
      end
    end
    # add this session_id to the new channels
    channels.each do |channel|
      REDIS_CLIENT.sadd channel,session_id
    end
    REDIS_CLIENT.HSET "session_id_channels", session_id, channels
  end
    
  def send_chat_message
    channel = session["#{params[:type]}_chat_channel"]
    logger.debug "\n\nPublish the chat message to #{params[:type]} to channel: #{channel}\n\n\n"
    Juggernaut.publish(channel, {:act=>'update_chat', :name=>@live_node.name,  :msg=>params[:msg]}, :except => request.headers["X-Juggernaut-Id"] )
  end

  def chat_form
    
  end
          
  def observer       
  
  end
  
  def add_session_form
    @live_session = flash[:live_session] || params[:id].nil? ? LiveSession.new : LiveSession.find(params[:id])
  end
  
  def add_session_post
    if params[:live_session].nil? || params[:live_session][:id].nil? || params[:live_session][:id] == ''
      @live_session = LiveEvent.find(params[:event_id]).live_sessions.create(params[:live_session])
    else
      @live_session = LiveSession.find(params[:live_session][:id])
      @live_session.attributes = params[:live_session]
      @live_session.save
    end
    
    if @live_session.errors.empty?
      redirect_to :live_coordinator
    else
      flash[:live_session] = @live_session
      redirect_to :add_live_session
    end
  end
  
  def delete_session_post
    LiveSession.find(params[:id]).destroy
    redirect_to :live_coordinator
  end
  
  def add_node_form
    @live_node = flash[:live_node] || params[:id].nil? ? LiveNode.new : LiveNode.find(params[:id])
    @parent_options = [['Select one',-1]] + LiveEvent.find( params[:event_id]).live_nodes.collect{ |node| [node.name,node.id]}
    @role_options = [['Select one',-1], ['Coordinator','coord'], ['Themer', 'theme'], ['Scribe','scribe']]
  end
  
  def add_node_post
    if params[:live_node].nil? || params[:live_node][:id].nil? || params[:live_node][:id] == ''
      @live_node = LiveEvent.find(params[:event_id]).live_nodes.create(params[:live_node])
    else
      @live_node = LiveNode.find(params[:live_node][:id])
      @live_node.attributes = params[:live_node]
      @live_node.save
    end
    
    if @live_node.errors.empty?
      redirect_to :live_coordinator
    else
      flash[:live_node] = @live_node
      redirect_to :add_live_node
    end
  end
  
  def delete_node_post
    LiveNode.find(params[:id]).destroy
    redirect_to :live_coordinator
  end
  
  
  
  
  def get_tp_test_ids
    group_range = params[:group_range].split('..').map{|d| Integer(d)}
    ltp_ids = LiveTalkingPoint.select('id').where(:live_session_id => params[:live_session_id], :group_id => group_range[0]..group_range[1] ).collect{|ltp| ltp.id}.shuffle
    render( :template => 'ce_live/get_tp_test_ids.js', :locals =>{:live_talking_point_ids => ltp_ids})
  end
  
  def post_talking_point_from_group
    
    # I want to use session to determine 
    # live_session_id
    # group_id
    # channel

    # a table identifier is coded into the node name
    group_id = @live_node.name.match(/\d+/)
    if group_id.nil?
      group_id = 0
    else
      group_id = group_id[0].to_i
    end

    # how do I determine the letter to give this talking point  
    last = LiveTalkingPoint.select('id_letter').where(:live_session_id => params[:s_id], :group_id => group_id).order('id DESC').limit(1)
    if last.empty?
      id_letter = 'A'
    else
      id_letter = last[0].id_letter.succ
    end

    ltp = LiveTalkingPoint.create live_session_id: params[:s_id], group_id: group_id, text: params[:text],
      pos_votes: params[:votes_for], neg_votes: params[:votes_against], id_letter: id_letter

    Juggernaut.publish(session[:table_chat_channel], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
    render( :template => 'ce_live/post_talking_point_from_group.js', :locals =>{:live_talking_point => ltp})
  end
  
  def post_theme_update
    
    # I want to use session to determine 
    # live_session_id
    # group_id
    # channel

    logger.debug "\n\n\n************ post_theme_update\n\n#{params.inspect}\n\n\n"

    case params[:act]
      
      when /update_theme_text/
        logger.debug "do update_theme_text"
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        @live_theme.text = params[:text]
        @live_theme.save
      when /update_theme_examples/
        logger.debug "update_list_examples"
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        @live_theme.example_ids = params[:example_ids].nil? ? '' : params[:example_ids].join(',')
        @live_theme.save
      when /new_list/ 
        logger.debug "new_list"
        @live_theme = LiveTheme.create live_session_id: params[:live_session_id], 
          themer_id: @live_node.id, text: params[:text], order_id: 0, live_talking_point_ids: params[:ltp_ids]
          
        # replace the temp list_id with the new one returned by @live_theme.id
        list_ids = []
        params[:list_ids].each do |li|
          if li == params[:list_id]
            list_ids.push @live_theme.id
          else
            list_ids.push li
          end
        end
        @live_theming_session = LiveThemingSession.find_or_create_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
        @live_theming_session.theme_group_ids = list_ids.join(',')
        @live_theming_session.save
          
        
      when /remove_list/
        logger.debug "remove_list"
        @live_theme = LiveTheme.find_by_id( params[:list_id]).destroy
        
        list_ids = []
        params[:list_ids].each do |li|
          if li != params[:list_id]
            list_ids.push li
          end
        end
        
        @live_theming_session = LiveThemingSession.find_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
        @live_theming_session.theme_group_ids = list_ids.join(',')
        @live_theming_session.save


      when /reorder_lists/
        logger.debug "reorder_lists"
        @live_theming_session = LiveThemingSession.find_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
        @live_theming_session.theme_group_ids = params[:list_ids].join(',')
        @live_theming_session.save
        
      when /add_misc_live_talking_point/
        logger.debug "add_misc_live_talking_point"
        @live_theming_session = LiveThemingSession.find_or_create_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
        @live_theming_session.unthemed_ids = params[:ltp_ids].nil? ? '' : params[:ltp_ids].join(',')
        @live_theming_session.save
      when /remove_live_talking_point/
        logger.debug "remove_live_talking_point"
      when /receive_live_talking_point/, /remove_live_talking_point/, /update_list_idea_ids/
        logger.debug "receive/remove_live_talking_point act: #{params[:act]}"

        @live_theme = LiveTheme.find_by_id( params[:list_id])
        
        if params[:ltp_ids].class.to_s == 'Array'
          ltp_ids = params[:ltp_ids].map{|d| d.to_i}.uniq.join(',')
        else
          ltp_ids = params[:ltp_ids].scan(/\d+/).uniq.join(',')
        end
        
        @live_theme.live_talking_point_ids = params[:ltp_ids].nil? ? '' : ltp_ids
        @live_theme.save
        
      else
        logger.debug "I do not know how to handle a request like this\nparams.inspect"
    end

    #ltp = LiveTalkingPoint.create live_session_id: params[:s_id], group_id: @live_node.id, text: params[:text],
    #  pos_votes: params[:votes_for], neg_votes: params[:votes_against], id_letter: id_letter
    #
    #Juggernaut.publish(session[:table_chat_channel], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
    render( :template => 'ce_live/post_theme.js', :locals =>{:live_talking_point => nil})
  end
  
  def get_templates
    # Set up all of the data I need for the templates to run
    # Build the templates in the templates.js template which will insert the HTML in script blocks text/html to hide them from browser processing
    # Add the directives to templates.js
    # Compile the templates when this loads into the browser


    old_ts = Time.local(2020,1,1)
    newer_ts = Time.local(2025,1,1)

    @live_talking_point = LiveTalkingPoint.new(:created_at => old_ts, :updated_at => newer_ts)

    # what do I need to know for the comment template?
    @live_talking_point.text = ''
    @live_talking_point.id = 0

    # the templates are built in get_templates.js
    render :template => 'ce_live/get_templates.html', :layout => false #, :content_type => 'application/javascript'
    
  end
  
  def session_test
    ltps = LiveTalkingPoint.where(:live_session_id => params[:sid], :group_id => params[:gid] )
    
    while ltps.size > 0
      ltp = ltps.sample
      ltps.delete ltp
      Juggernaut.publish(params[:ch], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
      sleep(1.seconds)
    end
    
    render :text => 'live talking points have been sent'
    
  end
  
  def sign_in_form
    # show the sign in form
    flash.keep # keep the info I saved till I successfully process the sign in
    render :template => 'ce_live/sign_in_form', :layout => 'ce_live'
  end
  
  def sign_in_post
    params[:event_id] = flash[:params][:event_id] if flash[:params]
    params[:event_id] ||= 1
    @live_node = LiveNode.find_by_live_event_id_and_password_and_username(params[:event_id],params[:password],params[:user_name])

    if @live_node
      session[:live_node_id] = @live_node.id
      if flash[:fullpath]
        redirect_to flash[:fullpath]
      else
        redirect_to :live_coordinator
      end
    else # no live_event_staff was retrieved with password and email
      flash.keep # keep the info I saved till I successfully process the sign in
      logger.debug "No valid member for username/password"
      flash[:notice] = "Invalid username/password combination for this event"
      redirect_to sign_in_all_path(:controller=> params[:controller], :user_email=>params[:user_email])
    end # end if member
  end
  
  def sign_out
    session.delete :live_node_id
    reset_session
    flash[:notice] = "Signed out"
    redirect_to :controller=> 'welcome', :action => "index"
  end
  
  
  protected
  
  def identify_node
    @live_node = LiveNode.find_by_id(session[:live_node_id])
  end
  
  def authorize
    logger.silence(3) do
      if @live_node.nil?
        flash[:fullpath] = request.fullpath
        flash[:params] = request.params
        flash[:notice] = "Please sign in to continue"
        #redirect_to :action=>'sign_in_form'
        redirect_to sign_in_all_path(:controller=> params[:controller])
      end
    end
  end
  
  def not_authorized
    render :template => 'ce_live/not_authorized', :layout => 'ce_live'
  end
  
end
