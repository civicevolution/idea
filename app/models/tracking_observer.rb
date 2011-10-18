class TrackingObserver < ActiveRecord::Observer
    
   observe :comment, :talking_point, :answer, :endorsement, :proposal_idea, :invite, :content_report, :initiative_members, :talking_point_acceptable_rating, :talking_point_preference, :answer_rating
   
    def after_create(model)
      #TrackingNotifications.delay.process_event( {:event => 'after_create', :model => model} )
      TrackingNotifications.process_event( {:event => 'after_create', :model => model} )
	  end

    def after_update(model)
      #TrackingNotifications.delay.process_event( {:event => 'after_update', :model => model} )
      TrackingNotifications.process_event( {:event => 'after_update', :model => model} )
	  end
  
end
