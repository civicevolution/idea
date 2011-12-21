module CallToActionHelper
  
  def add_call_to_action(data = {} )
    
		conf = YAML.load_file("#{Rails.root}/config/calls_to_action.yaml")

    primary_haml = ''
    secondary_haml = ''
    
    debug = false
    #debug = true if data[:id] == 'worksheet_cta'
    
    # find a set that applies, or use the set if only one
    conf['init_1'][data[:id]].each_value do |option|
      debugger if debug
      # iterate through the options to find the one(s) that match
      if option['test'].nil? || eval(option['test'])
        option['haml_strings'].each_pair do |key,haml_string|
          if haml_string['test'].nil? || eval(haml_string['test'])
            if key.match(/primary/) 
              primary_haml += haml_string['haml'] 
            else
              secondary_haml += haml_string['haml'] 
            end
          end #haml_string test
        end #haml_strings
      end # if option['test']
    end #options
    debugger if debug
    if primary_haml != '' || secondary_haml != ''
      render :partial => 'shared/cta', :locals => { :primary => primary_haml, :secondary => secondary_haml, :custom_locals=>data }
    end
    
  end
  
end
