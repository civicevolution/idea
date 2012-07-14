class ItemVersions < ActiveRecord::Base
  attr_accessible :item_id, :item_type, :ver, :text
  
end
