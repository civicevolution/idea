# move this to library when it is stable
# /lib is not reloaded in dev, but putting this module in models means it will be reloaded each time it is referenced
module LibCe

  require 'net/http'
  require 'json'
  require 'uri'
  
  def sendApeNotification(params,session)
 
    debug = true;
    if debug
      if params[:debug_save_id]
        logger.debug "Save these params to session with id: #{params[:debug_save_id]}"
        session[:ape] = {} unless session[:ape]
        session[:ape][params[:debug_save_id].to_s] = params
      elsif params[:debug_write_id] && session[:ape]
        logger.debug "Write saved params from session with id: #{params[:debug_write_id]}"
        if session[:ape][params[:debug_write_id]]
          params = session[:ape][params[:debug_write_id].to_s]
        else
          return "No data saved in session[:ape] for id: #{params[:debug_write_id]}"
        end
      end
    end

#    logger.debug "sendApeNotificationv1 params: #{params.inspect}" if debug;

    if(params[:data][:html])
      params[:data][:html] = escape_json_text(params[:data][:html]) 
    end

    if(params[:data][:text])
      params[:data][:text] = escape_json_text(params[:data][:text]) 
    end
    
    if params[:data][:data]
      params[:data][:data][:text] = escape_json_text(params[:data][:data][:text])
      params[:data][:data][:uid] = params[:data][:uid] = rand.to_s
    else
      params[:data][:uid] = rand.to_s
    end
    
    if params[:data][:resource]
      params[:data][:resource][:title] = escape_json_text(params[:data][:resource][:title])
      params[:data][:resource][:description] = escape_json_text(params[:data][:resource][:description])
      params[:data][:resource][:link_url] = escape_json_text(params[:data][:resource][:link_url])
      params[:data][:resource][:resource_file_name] = escape_json_text(params[:data][:resource][:resource_file_name])
    end

    if(params[:data][:resource_link])
      params[:data][:resource_link] = escape_json_text(params[:data][:resource_link]) 
    end

    @data = make_ape_data
    @data['params']['channel'] = params[:channel]  # this will be the team number
    @data['params']['raw'] = params[:type]    # data | comment | rating , etc.
    
    #debugger
    params[:data].each { |key,value| @data['params']['data'][key] = value }

    #logger.debug("data: #{@data.inspect}")  if debug;

    serialized = [@data].to_json

    logger.debug "Team channel: serialized: #{serialized}"  if debug;

    logger.warn "----- Re activate APE notification"
    #http = Net::HTTP.new('0.ape.civicevolution.org', 80)
    ##http.set_debug_output $stderr  # show lots of debug messages
    #resp, data = http.get('/0/?' + serialized, nil )
    #@resp = resp
    #@data = data
    #
    #data  = JSON.parse @data # => [{"data"=>{"code"=>"400", "value"=>"BAD_PASSWORD"}, "time"=>"1264464788", "raw"=>"ERR"}]
    #
    #if data[0]['raw'] == 'ERR'
    #  logger.warn "----- Error transmitting to APE: #{data[0]['data'].inspect}"      
    #else
    #  logger.debug "+++++ APE accepted the message #{data[0]['data'].inspect}"
    #end
    
    #return serialized
    return serialized.gsub(/%25/,'%')


#    # I need to get the page #
#    # for chat it is the item_id and for other content is the 3rd topmost ancestor
#    if params[:page_channel]
#      page_channel = params[:page_channel]
#    elsif params[:type] == 'chat'
#      page_channel = 'page' + params[:data][:item_id]
#    else
#      item_id = params[:data][:item_id]
#      i = Item.find_by_id(item_id)
#      i.ancestors.match(/(\d+),(\d+),(\d+)/)
#      page_channel = 'page' + i.ancestors.match(/(\d+),(\d+),(\d+)/)[3]
#    end
#
##    logger.debug"@@@@@@@@@@@@@@@@@ send on channel #{page_channel}"
#    
#    # change the channel number and send again
#    # replace "channel":"team10005" with "channel":"pageXXXX"
#    serialized = serialized.sub(/"channel":"team\d+"/, '"channel":"' + page_channel + '"')
##    logger.debug "Page channel: serialized: #{serialized}"  if debug;    
#    
#    resp, data = http.get('/0/?' + serialized, nil )
#    @resp = resp
#    @data = data
#    
#    data  = JSON.parse @data # => [{"data"=>{"code"=>"400", "value"=>"BAD_PASSWORD"}, "time"=>"1264464788", "raw"=>"ERR"}]
#    
#    if data[0]['raw'] == 'ERR'
#      logger.debug "----- Error transmitting to APE: #{data[0]['data'].inspect}"      
#    else
#      logger.debug "+++++ APE accepted the message #{data[0]['data'].inspect}"
#    end
    
  end
  
  def escape_json_text(text)
    if text
      text = text.gsub(/"/,'%22').gsub(/[']/, '%27').gsub(/\n/,'%0A').gsub(/\\/,'%5C').gsub(/\?/,'%3f')
      text = URI.escape(text)
      return text
    end    
  end
  

  
private

  def make_ape_data
    return data = {
      "cmd" => "INLINEPUSH",
      "params"=>{
        'password'=> 'i3H7sS9WEp',
        "data"=> {
          'from'=> {
            "properties"=>{
              "name" => "system"
            }
          }
        }
      }
    }
  end  
  
end