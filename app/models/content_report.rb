class ContentReport < ActiveRecord::Base
  attr_accessible :item_id, :member_id, :sender_name, :sender_email, :report_type, :text, :content_type, :content_id
  
end
