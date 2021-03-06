class HelpController < ApplicationController
  layout "plan", :except => [:something_else]
  skip_before_filter :authorize
   
  def help_page
    
    init_id = params[:_initiative_id]
    conf = YAML.load_file("#{Rails.root}/config/help.yaml")		
    
    # create a table of contents
    toc = {}			
    conf['help'].each_pair do |key,value|
      value.each_value do |option|
        if (option['init_id'] == 'all') || ([ option['init_id'] ].flatten.include? init_id)
          toc[key] = option['title']
          break
        end
      end
    end
    
    default_page = {:id => params[:topic] || 'Introduction'}
    def_conf = conf['help'][ default_page[:id] ] || conf['help'][ 'Introduction' ]
    def_conf.each_value do |option|
      if (option['init_id'] == 'all') || ([ option['init_id'] ].flatten.include? init_id)
        default_page[:title]  = option['title']
        default_page[:haml]  = option['haml']
        break
      end
    end
    
    introduction_haml = 'Need to make introduction'
    conf['help']['Introduction'].each_value do |option|
      if (option['init_id'] == 'all') || ([ option['init_id'] ].flatten.include? init_id)
        introduction_haml = option['haml']
        break
      end
    end
    
    render :template=>'help/help_page', :layout => 'plan', 
      :locals => { :inc_js => 'none', :toc => toc, :default_page => default_page, :introduction_haml => introduction_haml}
    
  end

  def short_help
    respond_to do |format|
      format.js { render 'help/short_help_page' }
      format.html { render 'help/short_help_page' }
    end
  end
  
  def help_topic
    topic_id = params[:id].size > 0 ? params[:id] : 'Introduction'
    conf = YAML.load_file("#{Rails.root}/config/help.yaml")		
    title = haml = nil
    def_conf = conf['help'][ topic_id ] || conf['help'][ 'Introduction' ]
    def_conf.each_value do |option|
      if (option['init_id'] == 'all') || ([ option['init_id'] ].flatten.include? params[:_initiative_id])
        title = option['title']
        haml = option['haml']
        break
      end
    end
    render :template=> 'help/help_topic', :layout => false, :locals => {:title=>title, :haml=>haml}
  end  
     
  def visual_help
    render :template=>'help/visual_help', :layout => 'plan', :locals => { :inc_js => 'none'}
    
  end

  def help_endorse_proposal

  end
  
  def help_develop_proposal
    
  end

  def help_quick_instructions_pi
    
  end
  
  def help_answer_question
    
  end
  
  def help_curate_show_path
    
  end
  
  
end

