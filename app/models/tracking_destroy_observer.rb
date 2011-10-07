class TrackingDestroyObserver < ActiveRecord::Observer
    
   observe :talking_point_preference
   
    def after_destroy(model)
      TrackingNotifications.process_event( {:event => 'after_destroy', :model => model} )
	  end
  
end
