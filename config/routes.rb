G3::Application.routes.draw do |map|
  
  get "profile/index"

  get "profile/upload_photo"

  get "profile/my_teams"

  get "sign_in/sign_in"

  get "sign_in/sign_out"

  get "sign_in/reset_password"

  get "sign_in/change_password"

  get "registration/register"

  get "registration/request_confirmation_email"

  get "registration/confirm_registration"

  get "plan/index"
  
  get "plan/suggest_new_idea"
  
  post "plan/submit_proposal_idea"
  
  get 'plan/review_proposal_idea/:id', :controller => 'plan', :action => 'review_proposal_idea', :requirements => { :id => /\d+/ }
  
  post "plan/approve_proposal_idea", :controller => 'plan', :action => 'approve_proposal_idea'
  
  get 'plan/:team_id/new_content(/:time_stamp)' => 'plan#new_content'

  #match 'plan/:id', :controller => 'plan', :action => 'index', :requirements => { :id => /\d+/ }
  match 'plan/:id', :controller => 'plan', :action => 'summary', :requirements => { :id => /\d+/ }
  match 'proposal/:id', :controller => 'plan', :action => 'summary', :requirements => { :id => /\d+/ }, :as=> 'proposal'

  resources :answer_diffs

  resources :talking_point_versions

  resources :talking_point_preferences

  resources :talking_point_acceptable_ratings

  resources :talking_points

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

  post "questions/:question_id/what_do_you_think", :to => "talking_points#create_question_talking_point", :constraints => lambda { |params| params[:input_type] ==  'talking_point'}
  post "questions/:question_id/what_do_you_think", :to => "comments#create_question_comment", :constraints => lambda { |params| params[:input_type] == 'comment'}
  post "questions/:question_id/what_do_you_think", :to => "questions#what_do_you_think", :constraints => lambda { |params| params[:input_type].nil?}

  get "questions/:question_id/worksheet" => "questions#worksheet", :as => :question_worksheet
  
  post "talking_points/:talking_point_id/create", :to => 'comments#create_talking_point_comment'
  
  post "talking_points/:talking_point_id/rate", :to => 'talking_point_acceptable_ratings#rate_talking_point'
  post "talking_points/:talking_point_id/prefer", :to => 'talking_point_preferences#prefer_talking_point'

  get "comments/:comment_id/comments", :to => 'comments#comment_comments'
  post "comments/:comment_id/add_comment", :to => 'comments#create_comment_comment'
  post "talking_points/:talking_point_id/add_comment", :to => 'comments#create_talking_point_comment'

  map.resources :resources

  map.resources :comments

  map.resources :answers

  map.resources :questions

  map.resources :members

  map.resources :teams

  map.resources :initiatives
  
  root :to => 'welcome#index'
  match 'about' => 'welcome#about', :as=>'ce_about'
  match 'home' => 'welcome#home', :as=>'ce_home'
  get 'contact_us' => 'welcome#contact_us', :as=>'ce_contact_us'
  post 'contact_us' => 'welcome#contact_us_post', :as=>'ce_contact_us_post'

  match 'subscribe' => 'welcome#subscribe'
  get 'get_started' => 'welcome#get_started'
  post 'get_started' => 'welcome#get_started_post'




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
  
 
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  #if APP_NAME == 'civic'
  #  map.root :controller => "welcome", :action=>'home'
  #else
  #  map.root :controller => "welcome", :action=>'index'
  #end
  
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.



  #if APP_NAME == 'civic'
  #  map.root :controller => "welcome", :action=>'home'
  #else
  #  map.root :controller => "welcome", :action=>'index'
  #end
  
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  
#  map.resources :pages

 
  
  
end
