class TrackingObserver < ActiveRecord::Observer
    
   observe :comment, :idea, :idea_rating, :talking_point, :answer, :endorsement, :proposal_idea, :invite, :content_report, :initiative_members, :talking_point_acceptable_rating, :talking_point_preference, :answer_rating
   
    def after_create(model)
      if Rails.env == 'production'
        TrackingNotifications.delay.process_event( {:event => 'after_create', :model => model} )
      else # don't delay in DEV to make debugging easier
        #TrackingNotifications.process_event( {:event => 'after_create', :model => model} )
        TrackingNotifications.delay.process_event( {:event => 'after_create', :model => model} )
      end
	  end

    def after_update(model)
      if Rails.env == 'production'
        TrackingNotifications.delay.process_event( {:event => 'after_update', :model => model} )
      else # don't delay in DEV to make debugging easier
        #TrackingNotifications.process_event( {:event => 'after_update', :model => model} )
        TrackingNotifications.delay.process_event( {:event => 'after_update', :model => model} )
      end
	  end
  
end
