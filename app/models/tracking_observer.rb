class TrackingObserver < ActiveRecord::Observer
    
   observe :comment, :talking_point, :answer, :endorsement, :proposal_idea
   
    def after_create(model)
      TrackingNotifications.process_event( {:event => 'after_create', :model => model} )
	  end

    def after_update(model)
      TrackingNotifications.process_event( {:event => 'after_update', :model => model} )
	  end
  
end
