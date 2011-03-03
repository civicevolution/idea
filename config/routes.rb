G3::Application.routes.draw do |map|
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
    map.root :controller => "welcome", :action=>'index'
  #end
  
  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

  map.connect 'idea/:id', :controller => 'idea', :action => 'index', :requirements => { :id => /\d+/ }

  map.connect 'team/:id', :controller => 'team', :action => 'index', :requirements => { :id => /\d+/ }
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  

  map.connect 'team/:action/:id', :controller => 'team', :action => 'welcome'
  map.connect 'team/:action/:id.:format', :controller => 'team', :action => 'welcome'
  
  map.connect 'mob/:action.:format', :controller => 'mob', :action => 'index'
  map.connect 'ape/:action.:format', :controller => 'ape', :action => 'chat', :format => 'html'
  
  
  
  map.resources :pages

  map.resources :resources

  map.resources :comments

  map.resources :answers

  map.resources :questions

  map.resources :members

  map.resources :teams

  map.resources :initiatives
 
  
  
end
