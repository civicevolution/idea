G3::Application.routes.draw do |map|
  
  get "profile/index"

  get "profile/upload_photo"

  get "profile/my_teams"

  get "sign_in/sign_in_form", :as => 'sign_in'
  
  get ":controller/sign_in_form", :action => 'sign_in_form', :as => 'sign_in_all'
  
  post ":controller/sign_in_post", :action => 'sign_in_post', :as => 'sign_in_post'
  post ":controller/temp_join_save_email", :action => 'temp_join_save_email', :as => 'temp_join_save_email'
  
  get "sign_in/sign_in"

  get "sign_in/sign_out"

  get "sign_in/reset_password_form", :as => 'reset_password_form'
  post "sign_in/reset_password_post", :as => 'reset_password_post'

  get "sign_in/password_reset_form", :as => 'password_reset_form'
  post "sign_in/password_reset_post", :as => 'password_reset_post'
  
  get "sign_in/change_password"

  get "registration/register"

  get "registration/request_confirmation_email"

  get "registration/confirm_registration"

  get "plan/index"
  
  get "plan/suggest_new_idea"
  
  post "plan/submit_proposal_idea", :as => 'submit_proposal_idea'
  
  get 'plan/review_proposal_idea/:id', :controller => 'plan', :action => 'review_proposal_idea', :requirements => { :id => /\d+/ }
  
  post "plan/approve_proposal_idea", :controller => 'plan', :action => 'approve_proposal_idea'
  
  get 'plan/:team_id/edit_summary', :to => 'teams#edit_summary_form', :as => 'edit_plan_summary'
  match 'plan/:team_id/edit_summary', :to => 'teams#edit_summary_post', :via => [:put, :post], :as => 'edit_plan_summary'

  match 'endorsements/:team_id/add', :to => 'endorsements#add_endorsement', :via => [:put, :post], :as => 'add_plan_endorsement'
  post 'endorsements/:team_id/delete', :to => 'endorsements#delete', :as => 'delete_plan_endorsement'
  post 'endorsements/:team_id/edit', :to => 'endorsements#edit', :as => 'edit_plan_endorsement'
  match 'endorsements/:team_id/update', :to => 'endorsements#update', :via => [:put, :post], :as => 'update_plan_endorsement'

  get 'plan/:team_id/new_content(/:time_stamp)' => 'plan#new_content', :as => 'new_content'

  #match 'plan/:id', :controller => 'plan', :action => 'index', :requirements => { :id => /\d+/ }
  match 'plan/:id', :controller => 'plan', :action => 'summary', :requirements => { :id => /\d+/ }, :as => 'plan'
  match 'proposal/:id', :controller => 'plan', :action => 'summary', :requirements => { :id => /\d+/ }, :as=> 'proposal'
  match "/idea/:id" => redirect("/plan/%{id}")

  post "questions/:question_id/what_do_you_think", :to => "questions#what_do_you_think", :as => 'what_do_you_think'
  get "questions/:question_id/what_do_you_think", :to => "questions#what_do_you_think_form", :as => 'what_do_you_think'

  get "questions/:question_id/worksheet" => "questions#worksheet", :as => :question_worksheet
  get "questions/:question_id/new_talking_points" => "questions#new_talking_points", :as => :question_new_talking_points
  get "questions/:question_id/all_talking_points" => "questions#all_talking_points", :as => :question_all_talking_points

  post "questions/:question_id/update_worksheet_ratings" => "questions#update_worksheet_ratings", :as => :update_worksheet_ratings


  get "questions/:question_id/new_comments" => "questions#new_comments", :as => :question_new_comments
  get "questions/:question_id/all_comments" => "questions#all_comments", :as => :question_all_comments
  
  post "talking_points/:talking_point_id/create", :to => 'comments#create_talking_point_comment'
  
  post "talking_points/:talking_point_id/rate", :to => 'talking_point_acceptable_ratings#rate_talking_point'
  post "talking_points/:talking_point_id/prefer", :to => 'talking_point_preferences#prefer_talking_point'
  get "talking_points/:talking_point_id/comments", :to => 'comments#talking_point_comments', :as => 'talking_point_comments'

  get "comments/:comment_id/comments", :to => 'comments#comment_comments', :as => 'comment_comments'
  get "comments/:comment_id/reply", :to => 'comments#comment_reply', :as => 'comment_reply'

  post "comments/:comment_id/add_comment", :to => 'comments#create_comment_comment', :as => 'add_comment_comment'
  post "talking_points/:talking_point_id/add_comment", :to => 'comments#create_talking_point_comment', :as => 'add_talking_point_comment'

  get "comments/:comment_id/report", :to => 'client_debug#report', :as => 'report_comment'
  get "talking_points/:talking_point_id/report", :to => 'client_debug#report', :as => 'report_talking_point'
  get "answer/:answer_id/report", :to => 'client_debug#report', :as => 'report_answer'
  post "comments/:comment_id/report", :to => 'client_debug#post_content_report', :as => 'report_comment'
  post "talking_points/:talking_point_id/report", :to => 'client_debug#post_content_report', :as => 'report_talking_point'
  post "answer/:answer_id/report", :to => 'client_debug#report', :as => 'report_answer'

  get "comments/:comment_id/edit", :to => 'comments#edit', :as => 'edit_comment'
  get "talking_points/:talking_point_id/edit", :to => 'talking_points#edit', :as => 'edit_talking_point'
  get "answer/:answer_id/edit", :to => 'answers#edit', :as => 'edit_answer'
  
  match "comments/:comment_id/update", :to => 'comments#update', :via => [:put, :post], :as => 'comment_update'
  match "talking_points/:talking_point_id/update", :to => 'talking_points#update', :via => [:put, :post], :as => 'talking_point_update'

  get "talking_points/:talking_point_id/versions", :to => 'talking_point_versions#history', :as => 'talking_point_versions'
  
  post "answer/:answer_id/edit", :to => 'answer#update', :as => 'answer_edit'

  post "talking_point_preferences/:question_id/update", :to => 'talking_point_preferences#update_preferences', :as => 'update_talking_point_preferences'
  
  get "cancel_comment_form", :to => 'comments#cancel_comment_form', :as => 'cancel_comment_form'

  get "request_help", :to => 'client_debug#request_help'
  post "request_help", :to => 'client_debug#request_help_post'
  
  root :to => 'welcome#index', :as => 'home'
  match 'about' => 'welcome#about', :as=>'ce_about'
  match 'home' => 'welcome#home', :as=>'ce_home'
  get 'contact_us' => 'welcome#contact_us', :as=>'ce_contact_us'
  post 'contact_us' => 'welcome#contact_us_post', :as=>'ce_contact_us_post'

  get 'members/new_profile' => 'members#new_profile_form', :as=>'new_profile_form'
  match 'members/new_profile' => 'members#new_profile_post', :via => [:put, :post], :as=>'new_profile_post'
  get 'members/:ape_code/edit_profile' => 'members#edit_profile_form', :as=>'edit_profile_form'
  match 'members/:ape_code/edit_profile' => 'members#edit_profile_post', :via => [:put, :post], :as=>'edit_profile_post'
  get 'members/:ape_code/profile' => 'members#edit_profile', :as=>'display_profile'
  match 'members/:ape_code/photo' => 'members#upload_member_photo', :via => [:put, :post], :as=>'upload_member_photo'

  get 'members/invite(/:team_id)' => 'members#invite_friends_form', :as => 'invite_friends_form'
  match 'members/invite(/:team_id)' => 'members#invite_friends_post', :via=>[:put, :post], :as => 'invite_friends_post'

  get 'notification/:team_id/settings' => 'notification#settings_form', :as => 'notification_settings_form'
  match 'notification/:team_id/update_settings' => 'notification#update_notification_settings', :via=>[:put, :post], :as => 'notification_settings_post'

  post 'initiatives/:initiative_id/join' => 'initiatives#join', :as => 'join_initiative'

  match 'subscribe' => 'welcome#subscribe'
  get 'get_started' => 'welcome#get_started'
  post 'get_started' => 'welcome#get_started_post'

  get 'visual_help' => 'help#visual_help'

  resources :answer_diffs

  #resources :talking_point_versions

  resources :talking_point_preferences

  resources :talking_point_acceptable_ratings

  resources :talking_points
  
  resources :resources
  resources :answers
  resources :comments
  resources :questions
  resources :members
  resources :teams
  resources :initiatives


  resources :questions do
		resources :talking_points do
		  collection do
	      post :create, :action => 'create_question_talking_point'  # this is the default action anyway
	      
	    end
		end
	end
	
  resources :talking_points do
		resources :comments do
		  collection do
		    get :index, :action => 'talking_point_comments'
	      post :add_comment, :action => 'create_talking_point_comment'
	    end
	  end
	end

  resources :questions do
		resources :comments do
		  collection do		  
	      get :index, :action => 'question_comments'
	      post :create, :action => 'create_question_comment'
	      #post :what_do_you_think, :controller => 'comments', :action => 'create_question_comment', :constraints => lambda {request.parameters[:input_type] == 'comment'}
	      #post :what_do_you_think, :controller => 'points', :action => 'create_question_talking_point', :constraints => lambda {request.parameters[:input_type] ==  'talking_point'}
	    end
	  end
	end

  #match ':controller/:action/:id'
  #match ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
    
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  
   # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
 
end
