class TrackingDestroyObserver < ActiveRecord::Observer
    
   observe :talking_point_preference
   
    def after_destroy(model)
      if Rails.env == 'production'
        TrackingNotifications.delay.process_event( {:event => 'after_destroy', :json => model.to_json} )
      else # don't delay in DEV to make debugging easier
        TrackingNotifications.process_event( {:event => 'after_destroy', :json => model.to_json} )
      end
      
	  end
  
end
