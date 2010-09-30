class Form < ActiveRecord::Base

# Stores input for randomly structured forms
# form contains member_id and form_name
# form_item contains form_id, name, and value

  def get_data
    # get all the key value pairs for this form
    form_data = { 'form_id' => self.id, 'form_name'=>self.form_name}
    items = FormItem.find_all_by_form_id(self.id)
    items.each do |i| 
      form_data[i.name] = i.value
    end
    return form_data
    
  end


  def self.save_form(params, member_id)
    logger.debug "Save the form specified in params: #{params} for member_id: #{member_id}"
    
    member_id = 0 if member_id.nil?
    
    form_id = params[:form_id].to_i
    if !(form_id > 0)
      logger.debug "create a new form record for params[:form_name] #{params[:form_name]} to get an id"
      form = Form.new :member_id=>member_id, :form_name=>params[:form_name]
      form.save
      form_id = form.id      
    end
  
    logger.debug "form_id: #{form_id}"
    
    # iterate through the hash
    params.each do |key,value|
      if(key!='form_id' && key!='form_name')
        logger.debug "key: #{key}: #{value}"
        form_item = FormItem.find_by_form_id_and_name(form_id,key)
        if form_item.nil?
          form_item = FormItem.new :form_id=>form_id, :name=>key
        end
        form_item.value = value
        form_item.save
      end
    end # end of params.each
    
    return form_id
  
  end


end
