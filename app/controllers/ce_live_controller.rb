class CeLiveController < ApplicationController
  layout "ce_live"
  prepend_before_filter :identify_node #, :except => [ :live_home, :sign_in_form, :sign_in_post]
  skip_before_filter :authorize , :only => [:live_home, :sign_in_form, :session_report, :get_templates, :vote, :vote_save, :session_themes]
  skip_before_filter :add_member_data# , :except => [ :logo, :rss ]
  
  def sign_in_form
    if @live_node
      live_home
    else
      # show the sign in form
      flash.keep # keep the info I saved till I successfully process the sign in
      render :template => 'ce_live/sign_in_form', :layout => 'ce_live', :locals=>{:get_templates => 'false'}
    end
  end
  
  def record_juggernaut_id
    if @live_node
      @live_node.jug_id = request.headers["X-Juggernaut-Id"]
      @live_node.save
    end
    render text: 'ok'
  end
  
  def live_home #role_page
    if @live_node.nil?
      @live_node = LiveNode.new
      @channels = []
      # show the sign in form
      flash.keep # keep the info I saved till I successfully process the sign in
      render :template => 'ce_live/sign_in_form', :layout => 'ce_live', :locals=>{:get_templates => 'false'}
      return
    end
    
    @channels = ["_event_#{@live_node.live_event_id}" ]
    case @live_node.role
      when 'scribe'
        begin
          group_id = @live_node.name.match(/\d+/)[0].to_i
        rescue 
          group_id = 'Unassigned - Please report this immediately'
        end
        @sessions = LiveSession.where( :live_event_id => @live_node.live_event_id ).order(:order_id)
        authorize_juggernaut_channels(request.session_options[:id], @channels )
        @page_data = {type: 'scribe home page'};
        render :template =>'ce_live/home_scribe', :locals=>{:group_id=>group_id, :get_templates => 'false'}
      
      when 'coord'
        @sessions = LiveSession.where( :live_event_id => @live_node.live_event_id ).order(:order_id)
        @subordinate_themers = LiveNode.where(:parent_id=>@live_node.id, :role=>'theme').order(:id)
        @subordinate_themers.each do |themer|
          names = ActiveRecord::Base.connection.select_values(%Q|SELECT name FROM live_nodes WHERE role = 'scribe' AND parent_id = #{themer.id}|)
          # get the numbers from the name and order them
          begin
            tables = names.map{|tab| tab.match(/\d+/)[0].to_i}.join(', ')
          rescue
            tables = 'Unassigned - Please report this immediately'
          end
          themer[:tables]  = tables
        end
        authorize_juggernaut_channels(request.session_options[:id], @channels )
        @page_data = {type: 'coord home page'};
        render :template =>'ce_live/home_coordinator', :locals=>{:get_templates => 'false'}
      
      when 'theme'
        @sessions = LiveSession.where( :live_event_id => @live_node.live_event_id ).order(:order_id)
        names = ActiveRecord::Base.connection.select_values(%Q|SELECT name FROM live_nodes WHERE role = 'scribe' AND parent_id = #{@live_node.id}|)
        # get the numbers from the name and order them
        begin
          @tables = names.map{|tab| tab.match(/\d+/)[0].to_i}.join(', ')
        rescue
          @tables = 'Unassigned - Please report this immediately'
        end
        authorize_juggernaut_channels(request.session_options[:id], @channels )
        @page_data = {type: 'themer home page'};
        render :template =>'ce_live/home_themer', :locals=>{:get_templates => 'false'}
      
      when 'dispatcher'
        @sessions = LiveSession.where( :live_event_id => @live_node.live_event_id ).order(:order_id)
        @event_nodes = LiveNode.where(:live_event_id => @live_node.live_event_id)
        @scribes = @event_nodes.select{|node| node.role == 'scribe'}
        @event_staff = @event_nodes.select{|node| node.role != 'scribe'}
        begin
           @scribes.sort!{|a,b| a.name.match(/\d+/)[0].to_i <=> b.name.match(/\d+/)[0].to_i }
            @event_staff.sort{|a,b| a.role <=> b.role}
        rescue
        end
        
        authorize_juggernaut_channels(request.session_options[:id], @channels )
        @page_data = {type: 'dispatcher home page'};
        render :template =>'ce_live/home_dispatcher', :locals=>{:get_templates => 'false'}
      
      when 'report'
        @sessions = LiveSession.where( :live_event_id => @live_node.live_event_id ).order(:order_id)
        authorize_juggernaut_channels(request.session_options[:id], @channels )
        @page_data = {type: 'reporter home page'};
        render :template =>'ce_live/home_reporter', :locals=>{:get_templates => 'false'}
        
      else
        render :template =>'ce_live/unrecognized_role', :locals=>{:table=>table}  
    end
    
    
  end  

  def channel_monitor   
    @page_title = "Channel monitor"

    @channels = ["_event_#{ params[:ch] || 2 }" ]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    render :template => 'ce_live/channel_monitor', :layout => 'ce_live', :locals=>{ :title=>'Channel monitor page for development and testing'}
  end
  
  def dispatcher   
    #return not_authorized unless @live_node.role == 'scribe'

    @page_title = "Dispatcher page"

    @channels = ["_event_#{params[:event_id]}"]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    render :template => 'ce_live/dispatcher', :layout => 'ce_live', :locals=>{ :title=>'Dispatcher page for CivicEvolution Live', :role=>'Scribe'}
  end
  
  def scribe  
    if @live_node.name.match(/\d+/).nil?
      @not_scribe_message = "You must be signed in as a table scribe to record allocation votes"
      group_id = 0
      #render :template => 'ce_live/home_scribe', :layout => 'ce_live', :locals=>{ :title=>'Scribe page for CivicEvolution Live', :role=>'Scribe'}
    else
      group_id = @live_node.name.match(/\d+/)[0].to_i
    end
    
    (page_type,session_id) = params['dest'].split('_')
  
    @session = LiveSession.find_by_id(session_id)

    @channels = ["_event_#{@live_node.live_event_id}" ]

    authorize_juggernaut_channels(request.session_options[:id], @channels )

    if page_type == 'standby'
      @page_data = {type: 'scribe standby'};
      render :template =>'ce_live/home_scribe', :locals=>{:group_id=>group_id, :get_templates => 'false'}
      
    elsif page_type == 'collect'
      # make sure this is in their roles
      return not_authorized unless @live_node.role == 'scribe'

      @page_title = "Table #{group_id}, Topic: #{@session.name}"

      primary_tag = ActiveRecord::Base.connection.select_value(%Q|SELECT tag FROM live_session_data WHERE live_session_id = #{@session.id} AND primary_field = true|)
      
      if primary_tag.nil?
        @live_talking_points = LiveTalkingPoint.where(:live_session_id => @session.id, :group_id => group_id).order('id ASC')
      else
        all_live_talking_points = LiveTalkingPoint.where(:live_session_id => @session.id, :group_id => group_id).order('id ASC')
        @live_talking_points = all_live_talking_points.select{|ltp| ltp.tag == primary_tag}
        
        @live_talking_points.each do |pltp|
          pltp.sub_ltp = all_live_talking_points.select{|ltp| ltp.id_letter == pltp.id_letter} - [pltp]
        end
        
      end
      
      @page_data = {type: 'enter talking points', session_id: @session.id, session_title: @session.name};
      
      if @session.outputs.size > 0
        render :template => 'ce_live/table_multi_input', :layout => 'ce_live', :locals=>{ :title=>'Scribe page for CivicEvolution Live', :role=>'Scribe'}
      else
        render :template => 'ce_live/table', :layout => 'ce_live', :locals=>{ :title=>'Scribe page for CivicEvolution Live', :role=>'Scribe'}
      end
    
    elsif page_type == 'allocation'
      
      @page_title = "Table #{group_id} Prioritisation for: #{@session.name}"

      if @session.source_session_id.nil? || @session.inputs.size > 0
        @source_session_id = @session.inputs[0].source_session_id
      else
        @source_session_id = @session.source_session_id
      end

      if LiveSession.find_by_id(@source_session_id).published
        @live_themes = LiveTheme.where("live_session_id = #{@source_session_id} AND order_id > 0").order('order_id ASC')
        @live_themes.reject!{ |theme| theme.visible == false }
        @table_id = @live_node.name.match(/\d+/)
        @table_id = @table_id.nil? ? 0 : @table_id[0].to_i
        @voter_id = params[:voter_id]

        # get the voter_ids that have already voted
        @voters = LiveThemeAllocation.get_voters(@session.id, @table_id)

      else
        @warning = "We're sorry, the results of this session have not been published yet"
      end
      @page_data = {type: 'allocate', session_id: @session.id, session_title: @session.name};

      render :template => 'ce_live/session_allocation_voting', :layout => 'ce_live', :locals=>{ :title=>'Prioritisation voting'}
    else
      render :template => 'ce_live/home_scribe', :layout => 'ce_live', :locals=>{ :title=>'Scribe page for CivicEvolution Live', :role=>'Scribe'}
    end

  end
  
  def event_setup    
    
    session[:live_node_id] = @live_node.id
    @page_title = "Event setup page"
    
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'coord'
    @event = LiveEvent.find( params[:event_id])
    @event_sessions = LiveSession.includes(:inputs, :outputs).where(:live_event_id => params[:event_id])
    @event_nodes = LiveNode.where(:live_event_id => params[:event_id])
    @channels = ["_event_#{params[:event_id]}"]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    @page_data = {type: 'event setup'};
    render :template => 'ce_live/event_setup', :layout => 'ce_live', :locals=>{ :title=>'Cordinator page for CivicEvolution Live', :role=>'Coordinator'}
  end



  def session_report        
    @session = LiveSession.find_by_id(params[:session_id])
    
    # open to the public
    
    @live_node = LiveNode.first
    
    @page_title = "Results for: #{@session.name}"
    
    @live_theming_session = LiveThemingSession.where(:live_session_id => @session.id, :themer_id => 1 )
    @live_themes_unordered = LiveTheme.where(:live_session_id => @session.id, :themer_id => 1 )
    # i need to put the live_themes in the order according to @live_theming_session.theme_group_ids
    @live_themes = []
    
    @live_theming_session.each do |theme_session|
      if !theme_session.nil?
        group_ids = theme_session.theme_group_ids
        - if !group_ids.nil?
          group_ids.split(',').each do |id|
            @live_themes.push @live_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
          end
        end
      end
    end

    @live_themes.compact!
    
    @page_data = {type: 'session report'};
    # I now have the themes in order
    render :template => 'ce_live/session_report', :layout => 'ce_live', :locals=>{ :inc_js => 'none', :title=>'Theming coordination page', :role=>'Public'}

  end


  
  def macro_themer        
    @session = LiveSession.find_by_id(params[:session_id])
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'coord'
    
    @themers = LiveNode.where(role: 'theme', parent_id: @live_node.id ).order('name ASC')
    
    @page_title = "Macro theming for: #{@session.name}"

    source_session_id = @session.id
    source_input_tags = ['default']
    if @session.inputs.size == 0
      
      @live_theming_session = LiveThemingSession.where(:live_session_id => @session.id)
      @live_themes_unordered = LiveTheme.where(:live_session_id => @session.id)

    else
      # first get my themes and theming data
      @live_themes_unordered = LiveTheme.where(:live_session_id => @session.id)
      @live_theming_session = LiveThemingSession.where(:live_session_id => @session.id)
      
      # now load the micro_theming data for each input
      source_input_tags = []
      @session.inputs.each do |inp|
        @live_themes_unordered += LiveTheme.where(:live_session_id => inp.source_session_id, :tag => inp.tag)
        @live_theming_session += LiveThemingSession.where(:live_session_id => inp.source_session_id, :tag => inp.tag)
        
        source_session_id = inp.source_session_id
        source_input_tags.push( inp.tag )
      end
    end

    if @session.outputs.size == 0
      output_tag = 'default'
    else
      primary_output_field = @session.outputs.detect{|o| o.primary_field } || @session.outputs[0]
      output_tag = primary_output_field.tag 
    end
    
    # i need to put the live_themes in the order according to @live_theming_session.theme_group_ids
    @live_themes = []
    @my_themes = []
    
    @live_theming_session.each do |theme_session|
      if !theme_session.nil?
        if theme_session.themer_id == @live_node.id
          if !theme_session.theme_group_ids.nil?
            theme_session.theme_group_ids.split(',').each do |id|
              @my_themes.push @live_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
            end
          end
        else
          if !theme_session.theme_group_ids.nil?
            theme_session.theme_group_ids.split(',').each do |id|
              @live_themes.push @live_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
            end
          end
        end
      end
    end
    
    @live_themes.compact!
    @my_themes.compact!
    
    # I now have the themes more or less in order

    example_tp_ids = []
    # determine which examples I need
    @live_themes.each do |theme|
      ex_ids = theme.example_ids
    	ex_ids = ex_ids.nil? ? [] : ex_ids.split(/[^\d]+/).map{|i| i.to_i}
      example_tp_ids += ex_ids
    end

    # get them as talking points
    
    @live_talking_points = LiveTalkingPoint.where(:id => example_tp_ids)  
    # then assign them to the themes
    @live_themes.each do |theme|
      ex_ids = theme.example_ids
      if !ex_ids.nil?
        ex_ids = ex_ids.split(/[^\d]+/).map{|i| i.to_i}
        example_talking_points = @live_talking_points.select{ |tp| ex_ids.include?(tp.id) }
      end
      theme[:examples] = example_talking_points
    end

    themed_tp_ids = []
    @my_themes.each do |theme|
		  if theme.id.to_i > 0
  			tp_ids = theme.live_talking_point_ids
  			tp_ids = tp_ids.nil? ? [] : tp_ids.split(/[^\d]+/).map{|i| i.to_i}
  			themed_tp_ids += tp_ids
  			theme[:themes] = tp_ids.map{ |id| @live_themes.detect{ |lt| lt.id == id.to_i} }.compact
  		end
		end
    
    #if !@live_theming_session.empty?
  	#	dont_fit_tp_ids = @live_theming_session[0].unthemed_ids.nil? ? [] : @live_theming_session[0].unthemed_ids.split(/[^\d]+/).map{|i| i.to_i}
  	#	themed_tp_ids += dont_fit_tp_ids
    #  @dont_fit_tp = @live_talking_points.select{ |tp| dont_fit_tp_ids.include?(tp.id) }
    #else
      @dont_fit_tp = []
    #end
    
    @macro_session = @session
    @live_themes = @live_themes.reject{ |tp| themed_tp_ids.include?(tp.id) }
    
    @channels = ["_event_#{@live_node.live_event_id}", "_session_#{source_session_id}_macrothemer" ]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    @disable_editing =  (@session.published || @live_node.role != 'coord') ? true : false
    @page_data = {type: 'macro theming', session_id: @session.id, source_session_id: source_session_id, 
      session_title: @session.name, output_tag: output_tag, source_input_tags: source_input_tags}
        
    render :template => 'ce_live/macro_themer', :layout => 'ce_live', :locals=>{ :title=>'Theming coordination page', :role=>'Themer'}
  end
  
  def macro_macro_themer  
    @session = LiveSession.find_by_id(params[:session_id])
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'coord'
    
    @themers = []
    
    @page_title = "Macro theming macro themes for: #{@session.name}"

    source_session_id = @session.id
    source_input_tags = ['default']
    # first get my themes and theming data
    @my_themes_unordered = LiveTheme.where(:live_session_id => @session.id)
    @live_theming_session = LiveThemingSession.where(:live_session_id => @session.id)
    
    # now load the macro_themes data for each input
    source_input_tags = []
    @live_themes_unordered = []
    @session.inputs.each do |inp|
      @live_themes_unordered += LiveTheme.where(:live_session_id => inp.source_session_id, 
        :tag => inp.tag, :visible => true).where('order_id > 0')
      
      source_session_id = inp.source_session_id
      source_input_tags.push( inp.tag )
    end

    if @session.outputs.size == 0
      output_tag = 'default'
    else
      primary_output_field = @session.outputs.detect{|o| o.primary_field } || @session.outputs[0]
      output_tag = primary_output_field.tag 
    end
    

    # i need to put my_themes in the order according to @live_theming_session.theme_group_ids
    @my_themes = []
    
    # use my live_theming session to put my macro macro themes in order
    
    @live_theming_session.each do |theme_session|
      if !theme_session.nil?
        if !theme_session.theme_group_ids.nil?
          theme_session.theme_group_ids.split(',').each do |id|
            @my_themes.push @my_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
          end
        end
      end
    end

    @my_themes.compact!
    
    # I now have the themes more or less in order

    # now attach the macro themes to my macro macro themes
    
    themed_tp_ids = []
    @my_themes.each do |theme|
		  if theme.id.to_i > 0
  			tp_ids = theme.live_talking_point_ids
  			tp_ids = tp_ids.nil? ? [] : tp_ids.split(/[^\d]+/).map{|i| i.to_i}
  			themed_tp_ids += tp_ids
  			theme[:themes] = tp_ids.map{ |id| @live_themes_unordered.detect{ |lt| lt.id == id.to_i} }.compact
  		end
		end
    
    #if !@live_theming_session.empty?
  	#	dont_fit_tp_ids = @live_theming_session[0].unthemed_ids.nil? ? [] : @live_theming_session[0].unthemed_ids.split(/[^\d]+/).map{|i| i.to_i}
  	#	themed_tp_ids += dont_fit_tp_ids
    #  @dont_fit_tp = @live_talking_points.select{ |tp| dont_fit_tp_ids.include?(tp.id) }
    #else
      @dont_fit_tp = []
    #end
    
    @macro_session = @session
    @live_themes = @live_themes_unordered.reject{ |tp| themed_tp_ids.include?(tp.id) }

    @channels = ["_event_#{@live_node.live_event_id}", "_session_#{source_session_id}_macrothemer" ]
    authorize_juggernaut_channels(request.session_options[:id], @channels )
    
    @disable_editing =  (@session.published || @live_node.role != 'coord') ? true : false
    @page_data = {type: 'macro theming', session_id: @session.id, source_session_id: source_session_id, 
      session_title: @session.name, output_tag: output_tag, source_input_tags: source_input_tags}
        
    render :template => 'ce_live/macro_themer', :layout => 'ce_live', :locals=>{ :title=>'Theming coordination page', :macro_macro_mode => 'true'}
  end
  
  def theme_final_edit

    @session = LiveSession.find_by_id(params[:session_id])
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'coord'
    
    @page_title = "Theme final edit for: #{@session.name}"
    if @session.inputs.size == 0
      source_session_id = @session.id
      @source_session_tag = 'default'
      @source_session = @session
      @live_theming_session = LiveThemingSession.where(:live_session_id => @session.id, :themer_id=>@live_node.id)
      @live_themes_unordered = LiveTheme.where(:live_session_id => @session.id, :themer_id=>@live_node.id)
    else
      source_session_id = @session.inputs[0].source_session_id
      @source_session_tag = @session.inputs[0].tag
      @source_session = LiveSession.find_by_id(source_session_id)
      @live_theming_session = LiveThemingSession.where(:live_session_id => source_session_id,
        :themer_id=>@live_node.id, :tag=>@session.inputs[0].tag)
        
      @live_themes_unordered = LiveTheme.where(:live_session_id => source_session_id,
        :themer_id=>@live_node.id, :tag=>@session.inputs[0].tag)

    end
    
    # i need to put the live_themes in the order according to @live_theming_session.theme_group_ids
    @my_themes = []
    ord = 0
    @live_theming_session.each do |theme_session|
      if !theme_session.nil?
        if !theme_session.theme_group_ids.nil?
          theme_session.theme_group_ids.split(',').each do |id|
            theme = @live_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
            if !theme.nil?
              theme.order_id = ord += 1
              @my_themes.push theme
            end
          end
        end
      end
    end
    
    @my_themes.compact!
    @my_themes.sort!{|a,b| a.order_id <=> b.order_id}

    @channels = ["_event_#{@live_node.live_event_id}" ]
    @disable_editing =  (@source_session.published || @live_node.role != 'coord') ? true : false
    @page_data = {type: 'final edit themes', session_id: @session.id, source_session_id: source_session_id, session_title: @session.name};
    render :template => 'ce_live/theme_final_edit', :layout => 'ce_live', :locals=>{ :title=>'Theme final edit page', :role=>'Themer'}
  end
  
  def group_talking_points
    return not_authorized unless @live_node.role == 'theme' || @live_node.role == 'coord'
    @live_talking_points = LiveTalkingPoint.where(group_id: params[:group_id], live_session_id: params[:session_id]).order('id ASC')
    render :template => 'ce_live/group_talking_points', :formats => [:js], :layout => false, :content_type => 'application/javascript'
  end

  def themer_themes
    return not_authorized unless @live_node.role == 'theme' || @live_node.role == 'coord'
    @themer = LiveNode.find_by_id(params[:themer_id])
    @live_themes = LiveTheme.where(themer_id: params[:themer_id], live_session_id: params[:session_id]).order('id ASC')
    
    example_tp_ids = []
    # determine which examples I need
    @live_themes.each do |theme|
      ex_ids = theme.example_ids
    	ex_ids = ex_ids.nil? ? [] : ex_ids.split(/[^\d]+/).map{|i| i.to_i}
      example_tp_ids += ex_ids
    end

    # get them as talking points
    
    @live_talking_points = LiveTalkingPoint.where(:id => example_tp_ids)  
    # then assign them to the themes
    @live_themes.each do |theme|
      ex_ids = theme.example_ids
      if !ex_ids.nil?
        ex_ids = ex_ids.split(/[^\d]+/).map{|i| i.to_i}
        example_talking_points = @live_talking_points.select{ |tp| ex_ids.include?(tp.id) }
      end
      theme[:examples] = example_talking_points
    end
    
    render :template => 'ce_live/themer_themes', :formats => [:js], :layout => false, :content_type => 'application/javascript'
  end

  def session_themes

    @session = LiveSession.find_by_id(params[:session_id])
    
    @page_title = "Themes for: #{@session.name}"

    if LiveSession.find_by_id(@session.id).published
      @live_themes = LiveTheme.where("live_session_id = #{@session.id} AND order_id > 0").order('order_id ASC')
      @live_themes.reject!{ |theme| theme.visible == false }
    else
      @warning = "We're sorry, the results of this session have not been published yet"
    end

    @channels = ["_event_#{@session.live_event_id}" ]
    @page_data = {type: 'view final themes'};
    render :template => 'ce_live/session_themes', :layout => 'ce_live', :locals=>{ :title=>'Themes', :role=>'Themer'}
  end

  def session_allocation_options
    
    @session = LiveSession.find_by_id(params[:session_id])
    
    @page_title = "Themes for: #{@session.name}"

    if LiveSession.find_by_id(@session.id).published
      @live_themes = LiveTheme.where("live_session_id = #{@session.id} AND order_id > 0").order('order_id ASC')
      @live_themes.reject!{ |theme| theme.visible == false }
    else
      @warning = "We're sorry, the results of this session have not been published yet"
    end

    @channels = ["_event_#{@session.live_event_id}" ]
    
    render :template => 'ce_live/session_allocation_options', :layout => 'ce_live', :locals=>{ :title=>'Prioritisation options', :role=>'Themer'}
  end
  
  def session_allocation_results
    @session = LiveSession.find_by_id(params[:session_id])
    
    @page_title = "Prioritisation for: #{@session.name}"

    if @session.source_session_id.nil? || @session.inputs.size > 0
      source_session_id = @session.inputs[0].source_session_id
    else
      source_session_id = @session.source_session_id
    end
    logger.debug "\n\n\nsource_session_id: #{source_session_id}\n\n\n"
    if LiveSession.find_by_id(source_session_id).published
      @live_themes = LiveTheme.where("live_session_id = #{source_session_id} AND order_id > 0").order('order_id ASC')
      @live_themes.reject!{ |theme| theme.visible == false }

      @allocated_points = LiveThemeAllocation.select("theme_id, sum(points) as points").where(:session_id => @session.id).group("theme_id")
      @total_points = 0
      @max_points = 0
      @allocated_points.each{|ap| @total_points += ap.points; @max_points = ap.points if ap.points > @max_points} 
      @voters = ActiveRecord::Base.connection.select_value(
        %Q| select count(*) FROM (SELECT distinct table_id, voter_id from live_theme_allocations where session_id = #{@session.id}) AS voters |)
      @live_themes.each do |theme|
        points = @allocated_points.detect{ |ap| ap.theme_id == theme.id}
        points = points.nil? ? 0 : points.points
        theme[:points] = points
        theme[:percentage] = @total_points > 0 ? points.to_f/@total_points : 0
      end

    else
      @warning = "We're sorry, the results of this session have not been published yet"
    end    

    @channels = ["_event_#{@session.live_event_id}" ]
    @page_data = {type: 'session allocation results'};
    render :template => 'ce_live/session_allocation_results', :layout => 'ce_live', :locals=>{ :title=>'Prioritisation results', :role=>'Themer'}
  end

  def allocate_save
    votes = {}

    begin
      params.each_pair do |key,value|
        if key.match(/^vote_\d+/) && value.to_i != 0
          votes[ key.match(/\d+/)[0].to_i] = value.to_i
        end
      end

      saved, @voter_id, err_msgs = LiveThemeAllocation.save_votes(params[:session_id], params[:table_id], params[:voter_id], votes)
    rescue Exception => e
      saved = false
    end

    if saved
      respond_to do |format|
        #format.html { render :summary, :layout => 'plan' }
        format.js { render :template => 'ce_live/vote_alloc_saved', :locals=>{:status=>'saved'} }
      end
      
    else
      respond_to do |format|
        #format.html { render :summary, :layout => 'plan' }
        format.js { render :template => 'ce_live/vote_alloc_saved', :locals=>{:status=>'failed', :err_msgs => err_msgs} }
      end
      
    end
  end

  def voter_session_allocations
    @votes = LiveThemeAllocation.where(:session_id =>params[:session_id], :table_id => params[:table_id], :voter_id => params[:voter_id])
    
  end
  
  def session_full_data
    @session = LiveSession.find_by_id(params[:session_id])
    
    @page_title = "Full data for: #{@session.name}"
    if LiveSession.find_by_id(@session.id).published
      # collect data according to the final edit source session type
      case @session.session_type
        when 'macrotheme'
          @macro_themes = LiveTheme.where(live_session_id: @session.id, visible: true).order('id ASC')
          @micro_themes = []
          @live_talking_points = []
          @session.inputs.each do |inp|
            @micro_themes += LiveTheme.where(:live_session_id => inp.source_session_id, :tag => inp.tag)
            LiveSession.find(inp.source_session_id).inputs.each do |tp_inp|
              @live_talking_points = LiveTalkingPoint.where(:live_session_id=>tp_inp.source_session_id, :tag => tp_inp.tag)
            end
          end

        when 'macromacrotheme'  
          @macro_themes = LiveTheme.where(live_session_id: @session.id, visible: true).order('id ASC')
          @micro_themes = []
          @session.inputs.each do |inp|
            @micro_themes += LiveTheme.where(:live_session_id => inp.source_session_id, :tag => inp.tag)
          end
      end
    else
      @warning = "We're sorry, the results of this session have not been published yet"  
    end

    @page_data = {type: 'session full data'};
    @channels = ["_event_#{@session.live_event_id}" ]
    render :template => 'ce_live/session_full_data', :layout => 'ce_live', :locals=>{ :title=>'Full session data', :role=>'Themer'}
  end
  
  
  
  def micro_themer         
    #return not_authorized unless @live_node.role == 'theme' || @live_node.role == 'coord'

    @session = LiveSession.find_by_id(params[:session_id])
    # make sure this is in their roles
    return not_authorized unless @live_node.role == 'theme' || @live_node.role == 'coord'
    
    if params[:id]
      themer_id = params[:id]
    else
      themer_id = @live_node.id
    end

    @presenter = LiveThemingSessions::MicroThemerPresenter.new(@live_node, params[:session_id], params[:id] )
    
    @disable_editing = @presenter.disable_editing
    @page_title = @presenter.page_title
    
    @channels = @presenter.channels
    authorize_juggernaut_channels(request.session_options[:id], @presenter.channels )
    
    @macro_session = LiveSession.find_by_sql(%Q|select * from live_sessions where id in (select live_session_id from live_session_data where io_type = 1 and source_session_id = #{@session.id})|)
    @macro_session = @macro_session.size > 0 ? @macro_session[0] : @session
    @disable_editing =  (@macro_session.published || @live_node.role != 'theme') ? true : false

    @page_data = @presenter.page_data

    render :template => 'ce_live/micro_themer', :layout => 'ce_live', :locals=>{ :title=>'Theming page for CivicEvolution Live'}
  end
    
  def ltp_to_jug
    ltp = LiveTalkingPoint.find(params[:id])
    Juggernaut.publish(params[:ch], {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
    render :text => "On juggernaut on channel; #{params[:ch]}, sent LiveTalkingPoint: #{ltp.inspect}", :content_type => 'text/plain'
  end

  def authorize_juggernaut_channels(session_id, channels )
    ## read all the channels for this session_id and clear them
    #old_channels = REDIS_CLIENT.HGET "session_id_channels", session_id
    #if old_channels
    #  JSON.parse(old_channels).each do |channel|
    #    REDIS_CLIENT.SREM channel,session_id
    #  end
    #end
    ## add this session_id to the new channels
    channels.each do |channel|
      REDIS_CLIENT.sadd channel,session_id
    end
    #REDIS_CLIENT.HSET "session_id_channels", session_id, channels
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
    render( :template => 'ce_live/add_session_form', :locals =>{:get_templates => 'false'})
  end
  
  def add_session_post
    if params[:live_session].nil? || params[:live_session][:id].nil? || params[:live_session][:id] == ''
      @live_session = LiveEvent.find(params[:event_id]).live_sessions.new(params[:live_session])
      @live_session.published = false
      @live_session.save
      if @live_session.session_type == 'group'
        @live_session.group_id = @live_session.id
        @live_session.save
      end
    else
      @live_session = LiveSession.find(params[:live_session][:id])
      @live_session.attributes = params[:live_session]
      @live_session.save
    end
    
    
    
    # save the inputs and outputs
    
    LiveSessionData.delete_all(:live_session_id => @live_session.id)
    
    if params[:in_1_tag] != ''
      @live_session.inputs.create io_type: 1, source_session_id: params[:in_1_source_session_id], tag: params[:in_1_tag]
   	end
    if params[:in_2_tag] != ''
      @live_session.inputs.create io_type: 1, source_session_id: params[:in_2_source_session_id], tag: params[:in_2_tag]
   	end

    if params[:out_1_tag] != ''
      @live_session.outputs.create io_type: 0, label: params[:out_1_label], tag: params[:out_1_tag], qty: params[:out_1_qty], 
        chars: params[:out_1_chars], height: params[:out_1_height], primary_field: params[:out_1_primary_field]
   	end
    if params[:out_2_tag] != ''
      @live_session.outputs.create io_type: 0, label: params[:out_2_label], tag: params[:out_2_tag], qty: params[:out_2_qty], 
        chars: params[:out_2_chars], height: params[:out_2_height], primary_field: params[:out_2_primary_field]
   	end
    
    if @live_session.errors.empty?
      redirect_to :live_event_setup
    else
      flash[:live_session] = @live_session
      redirect_to :add_live_session
    end
  end
  
  def delete_session_post
    LiveSession.find(params[:id]).destroy
    redirect_to :live_event_setup
  end
  
  def add_node_form
    @live_node = flash[:live_node] || params[:id].nil? ? LiveNode.new : LiveNode.find(params[:id])
    @parent_options = [['Select one',-1]] + LiveEvent.find( params[:event_id]).live_nodes.collect{ |node| [node.name,node.id]}
    @role_options = [['Select one',-1], ['Scribe','scribe'], ['Themer', 'theme'], ['Coordinator','coord'], ['Reporter','report'], ['Dispatcher', 'dispatcher']]
  end
  
  def add_node_post
    params[:live_node][:password] = params[:live_node][:password].strip.downcase
    params[:live_node][:username] = params[:live_node][:username].strip.downcase
    if params[:live_node].nil? || params[:live_node][:id].nil? || params[:live_node][:id] == ''
      @live_node = LiveEvent.find(params[:event_id]).live_nodes.create(params[:live_node])
    else
      @live_node = LiveNode.find(params[:live_node][:id])
      @live_node.attributes = params[:live_node]
      @live_node.save
    end
    
    if @live_node.errors.empty?
      redirect_to :live_event_setup
    else
      flash[:live_node] = @live_node
      redirect_to :add_live_node
    end
  end
  
  def delete_node_post
    LiveNode.find(params[:id]).destroy
    redirect_to :live_event_setup
  end
  
  
  
  
  def get_tp_test_ids
    group_range = params[:group_range].split('..').map{|d| Integer(d)}
    ltp_ids = LiveTalkingPoint.select('id').where(:live_session_id => params[:live_session_id], :group_id => group_range[0]..group_range[1] ).collect{|ltp| ltp.id}.shuffle
    render( :template => 'ce_live/get_tp_test_ids', :formats => [:js], :locals =>{:live_talking_point_ids => ltp_ids})
  end
  
  def post_talking_point_from_group
    #if LiveSession.find(params[:s_id]).published
    #  render( :template => 'ce_live/post_talking_point_from_group', :formats => [:js], :locals =>{:live_talking_point => nil})
    #  return
    #end
    
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

    if params[:text]
      # how do I determine the letter to give this talking point  
      last = LiveTalkingPoint.select('id_letter').where(:live_session_id => params[:s_id], :group_id => group_id).order('id DESC').limit(1)
      if last.empty?
        id_letter = 'A'
      else
        id_letter = last[0].id_letter.succ
      end

      ltp = LiveTalkingPoint.create live_session_id: params[:s_id], group_id: group_id, text: params[:text], tag: 'default',
        pos_votes: params[:votes_for], neg_votes: params[:votes_against], id_letter: id_letter
      
    else
      # I need the primary input tag for this session
      primary_tag = ActiveRecord::Base.connection.select_value(%Q|SELECT tag FROM live_session_data WHERE live_session_id = #{params[:s_id].to_i} AND primary_field = true|)
      
      last = LiveTalkingPoint.select('id_letter').where(:live_session_id => params[:s_id], :tag => primary_tag, :group_id => group_id).order('id DESC').limit(1)
      if last.empty?
        id_letter = 'A'
      else
        id_letter = last[0].id_letter.succ
      end

      sub_ltp = []
      primary_field_value = params["_tp_#{primary_tag}_1"]
      params.each_pair do |name,value|
        if name.match(/_tp_/)
          tag = name.match(/_tp_(.*)_\d$/)[1]
          if value.match(/\w/)
            new_ltp = LiveTalkingPoint.create live_session_id: params[:s_id], group_id: group_id, text: value, tag: tag,
              pos_votes: 0, neg_votes: 0, id_letter: id_letter
            if tag == primary_tag
              ltp = new_ltp
            else
              sub_ltp.push new_ltp
            end
          end
        end
      end
      ltp.sub_ltp = sub_ltp
    end
      
    Juggernaut.publish("_session_#{params[:s_id]}_microthemer_#{@live_node.parent_id}", {:act=>'theming', :type=>'live_talking_point', :data=>ltp})
    render( :template => 'ce_live/post_talking_point_from_group', :formats => [:js], :locals =>{:live_talking_point => ltp})
  end
  
  def post_theme_update
    
    # I want to use session to determine 
    # live_session_id
    # group_id
    # channel

    logger.debug "\n\n\n************ post_theme_update\n\n#{params.inspect}\n\n\n"
    
    
    #params[:act] == 'new_listXXX'
    #params[:list_id] = 123
    #@live_theme = LiveTheme.first
    #
    #render( :template => 'ce_live/post_theme', :formats => [:js], :locals =>{:live_talking_point => nil})
    #return 
    
    
    case params[:act]

      when 'update_macro_theme'
        logger.debug "do update_macro_theme"
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        @live_theme.text = params[:text]
        @live_theme.save
    
      when 'update_macro_theme_example'
        logger.debug "do update_macro_theme_example"
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        @live_theme.example_ids = params[:macro_theme_example_text]
        @live_theme.save
      
      when 'update_theme_text'
        logger.debug "do update_theme_text"
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        @live_theme.text = params[:text]
        @live_theme.save
        Juggernaut.publish("_session_#{params[:live_session_id]}_macrothemer", {:act=>'theming', :type=>'live_uTheme_update', :data=>@live_theme})
        
      when 'update_theme_examples'
        logger.debug "update_list_examples"
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        if params[:example_ids].nil?
          @live_theme.example_ids = ''
          @live_theme_examples = []
        else
          @live_theme.example_ids = params[:example_ids].join(',')
          @live_theme_examples = LiveTalkingPoint.where(id: params[:example_ids] )
        end
        @live_theme.save
        Juggernaut.publish("_session_#{params[:live_session_id]}_macrothemer", {:act=>'theming', :type=>'live_uTheme_examples', 
          :data=> {:live_theme_id=>params[:list_id], :examples => @live_theme_examples}})
        
        
      when 'new_list' 
        logger.debug "new_list"
        @live_theme = LiveTheme.create live_session_id: params[:live_session_id], tag: params[:output_tag],
          themer_id: @live_node.id, text: params[:text], order_id: 0, live_talking_point_ids: params[:ltp_ids], visible: true
          
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
        @live_theming_session.tag = params[:output_tag] unless params[:output_tag].nil? || params[:output_tag] == ''
        @live_theming_session.save
          
      when 'reorder_lists'
        logger.debug "reorder_lists"
        @live_theming_session = LiveThemingSession.find_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
        @live_theming_session.theme_group_ids = params[:list_ids].join(',')
        @live_theming_session.save
        
      when 'add_misc_live_talking_point'
        logger.debug "add_misc_live_talking_point"
        @live_theming_session = LiveThemingSession.find_or_create_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
        @live_theming_session.unthemed_ids = params[:ltp_ids].nil? ? '' : params[:ltp_ids].join(',')
        @live_theming_session.save
      when 'receive_live_talking_point', 'remove_live_talking_point', 'update_list_idea_ids'
        logger.debug "receive/remove_live_talking_point act: #{params[:act]}"
        if params[:ltp_ids].nil?
          ltp_ids = ''
        elsif params[:ltp_ids].class.to_s == 'Array'
          ltp_ids = params[:ltp_ids].map{|d| d.to_i}.uniq.join(',')
        else
          ltp_ids = params[:ltp_ids].scan(/\d+/).uniq.join(',')
        end
        
        if params[:list_id] == "misc"
          @live_theming_session = LiveThemingSession.find_or_create_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
          @live_theming_session.unthemed_ids = ltp_ids
          @live_theming_session.save
        else
          @live_theme = LiveTheme.find_by_id( params[:list_id])
          @live_theme.live_talking_point_ids = ltp_ids
          @live_theme.save
        end
        
      when 'update_final_theme_order'
        logger.debug 'update_final_theme_order'
        if params[:new_ids].class.to_s == 'Array'
          @new_ids = params[:new_ids].map{|d| d.to_i}.uniq.join(',')
        else
          @new_ids = params[:new_ids].scan(/\d+/).uniq.join(',')
        end
        
        @live_theming_session = LiveThemingSession.find_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
        @live_theming_session.theme_group_ids = @new_ids
        @live_theming_session.tag = params[:output_tag] unless params[:output_tag].nil? || params[:output_tag] == ''
        @live_theming_session.save
        
      when 'update_theme_text_and_example'
        if !params[:theme_id].match(/\d/).nil?
          @live_theme = LiveTheme.find_by_id( params[:theme_id])
          @live_theme.text = params[:theme]
          @live_theme.example_ids = params[:example]
          @live_theme.save
        else
          @live_theme = LiveTheme.create live_session_id: params[:live_session_id], tag: params[:output_tag],
            themer_id: @live_node.id, text: params[:theme], order_id: 0, example_ids: params[:example], visible: true
          @live_theming_session = LiveThemingSession.find_or_create_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
          ids = @live_theming_session.theme_group_ids ||= ''
          ids = ids.scan(/\d+/)
          ids.push( @live_theme.id )
          @live_theming_session.tag = params[:output_tag] unless params[:output_tag].nil? || params[:output_tag] == ''
          @live_theming_session.theme_group_ids = ids.map{|d| d.to_i}.uniq.join(',')
          @live_theming_session.save
          
        end
      
      when 'update_theme_visibility'
        LiveTheme.find_by_id(params[:theme_id]).update_attribute('visible',params[:visible])  
        
      when 'publish_session_themes'
        LiveSession.find_by_id(params[:live_session_id]).update_attribute('published',params[:new_publish_status])  
        # set the order_id for the live_themes
        
        @live_theming_session = LiveThemingSession.where(:live_session_id => params[:live_session_id], :themer_id=>@live_node.id)
        @live_themes_unordered = LiveTheme.where(:live_session_id => params[:live_session_id], :themer_id=>@live_node.id)
        if params[:new_publish_status] == 'true'
          # i need to put the live_themes in the order according to @live_theming_session.theme_group_ids

          ord = 0
          if !@live_theming_session.nil? && @live_theming_session.size > 0
            @live_theming_session = @live_theming_session[0]
            if !@live_theming_session.theme_group_ids.nil?
              @live_theming_session.theme_group_ids.split(',').each do |id|
                theme = @live_themes_unordered.detect{ |lt| lt.id.to_i == id.to_i}
                if !theme.nil?
                  theme.order_id = ord += 1
                  theme.save
                end
              end
            end
          end
        end
        
      when 'delete_theme_child'  
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        ltp_ids = @live_theme.live_talking_point_ids.scan(/\d+/).map{|d| d.to_i}
        ltp_ids = ltp_ids - [params[:idea_id].to_i]
        @live_theme.live_talking_point_ids = ltp_ids.uniq.join(',')
        
        # when a talking point is deleted from a uTheme, I need to update the examples if the TP was an example
        ex_ids = @live_theme.example_ids || ''
        ex_ids = ex_ids.scan(/\d+/).map{|d| d.to_i}
        if ex_ids.include?( params[:idea_id].to_i )
          ex_ids = ex_ids - [params[:idea_id].to_i]
          @live_theme.example_ids = ex_ids.uniq.join(',')
          if ex_ids.size == 0
            @live_theme_examples = []
          else
            @live_theme_examples = LiveTalkingPoint.where(id: ex_ids )
          end
          Juggernaut.publish("_session_#{params[:live_session_id]}_macrothemer", {:act=>'theming', :type=>'live_uTheme_examples', 
            :data=> {:live_theme_id=>params[:list_id], :examples => @live_theme_examples}})
          
        end
        @live_theme.save
        
      when 'delete_theme'
        @live_theme = LiveTheme.find_by_id( params[:list_id])
        if @live_theme.live_talking_point_ids.nil? || @live_theme.live_talking_point_ids.nil? != ''
          @live_theme.destroy          
          @remove_theme_id = @live_theme.id

          @live_theming_session = LiveThemingSession.find_by_live_session_id_and_themer_id( params[:live_session_id], @live_node.id)
          list_ids = @live_theming_session.theme_group_ids.scan(/\d+/).map{|d| d.to_i}
          list_ids = list_ids - [@remove_theme_id]
          @live_theming_session.theme_group_ids = list_ids.uniq.join(',')
          @live_theming_session.save
          
          Juggernaut.publish("_session_#{params[:live_session_id]}_macrothemer", {:act=>'theming', :type=>'live_uTheme_delete', 
            :data=> {:live_theme_id=>params[:list_id]}})
        end
        
        
      else
        logger.debug "I do not know how to handle a request like this\nparams.inspect"
    end

    render( :template => 'ce_live/post_theme', :formats => [:js], :locals =>{:live_talking_point => nil})
  end
  
  def get_templates
    # Set up all of the data I need for the templates to run
    # Build the templates in the templates.js template which will insert the HTML in script blocks text/html to hide them from browser processing
    # Add the directives to templates.js
    # Compile the templates when this loads into the browser


    old_ts = Time.local(2020,1,1)
    newer_ts = Time.local(2025,1,1)

    @live_talking_point = LiveTalkingPoint.new
    @live_talking_point.created_at = old_ts
    @live_talking_point.updated_at = newer_ts
    # what do I need to know for the comment template?
    @live_talking_point.text = ''
    @live_talking_point.id = 0
    @live_talking_point.pos_votes = 5
    
    @live_theme = LiveTheme.new
    @live_theme.created_at = old_ts
    @live_theme.updated_at = newer_ts
    
    @live_theme.id = 0
    @live_theme.themer_id = 0
    @live_theme.text = ''
    # the templates are built in get_templates.js
    render :template => 'ce_live/get_templates', :formats => [:html], :layout => false #, :content_type => 'application/javascript'
    
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
  
  def sign_in_post
    params[:event_id] = flash[:params][:event_id] if flash[:params]
    params[:session_id] = flash[:params][:session_id] if flash[:params]

    live_event = LiveEvent.find_by_event_code(params[:event_code])
    if live_event.nil?
      flash.keep # keep the info I saved till I successfully process the sign in
      logger.debug "Invalid event code"
      flash[:notice] = "Invalid event code"
      redirect_to sign_in_all_path(:controller=> params[:controller], :user_email=>params[:user_email], :event_code=>params[:event_code])
      return
    end
    
    event_id = live_event.id
            
    @live_node = LiveNode.find_by_live_event_id_and_password_and_username(event_id,params[:password].strip.downcase,params[:user_name].strip.downcase)

    if @live_node
      session[:live_node_id] = @live_node.id
      cookies[:event] = { :value => params[:event_code], :expires => Time.now + 48*60*60}
      if @live_node.role == 'scribe'
        cookies[:user_name] = { :value => params[:user_name], :expires => Time.now + 48*60*60}
        cookies[:password] = { :value => params[:password], :expires => Time.now + 48*60*60}
      end
      respond_to do |format|
        format.js { render 'ce_live/sign_in_acknowledge', :formats => [:js] }
        format.html { redirect_to live_home_path }
      end
    else # no live_event_staff was retrieved with password and email
      flash.keep # keep the info I saved till I successfully process the sign in
      logger.debug "Invalid username/password combination for this event code"
      flash[:notice] = "Invalid username/password combination for this event code"
      respond_to do |format|
        format.js { render 'ce_live/sign_in_form', :formats => [:js] }
        format.html { redirect_to sign_in_all_path(:controller=> params[:controller], :user_email=>params[:user_email], :event_code=>params[:event_code]) }
      end
      
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
    old_log_level = Rails.logger.level
	  Rails.logger.level = 3
    if @live_node.nil?
      flash[:fullpath] = request.fullpath
      flash[:params] = request.params
      flash[:notice] = "Please sign in to continue"
      #redirect_to :action=>'sign_in_form'
      redirect_to sign_in_all_path(:controller=> params[:controller])
    end
    Rails.logger.level = old_log_level
  end
  
  def not_authorized
    render :template => 'ce_live/not_authorized', :layout => 'ce_live'
  end
  
end
