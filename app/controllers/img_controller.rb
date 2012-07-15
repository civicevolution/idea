class ImgController < ApplicationController
  def logo
    if request.remote_ip != '76.14.65.54'  # don't log when I open an email
      #send_data data_string, :filename => 'logo.jpg', :type => 'image/jpeg', :disposition => 'inline'
      #logger.debug "Send the file with the code #{params[:id]}"
      sql = %Q|UPDATE call_to_action_emails_sents SET opened_email = now() at time zone 'UTC' 
      WHERE member_lookup_code_id = (SELECT id FROM member_lookup_codes WHERE code = '#{params[:id]}' LIMIT 1)|
      #logger.debug "request.remote_ip: #{request.remote_ip}"
      #logger.debug "sql: #{sql}"
      ActiveRecord::Base::connection().update( sql )
    end
    send_file "#{Rails.root.to_s}/public/assets/1x1.gif", :type => 'image/gif', :disposition => 'inline'
  end

end
