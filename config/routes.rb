G3::Application.routes.draw do

  match "/ce-video" => redirect("https://www.youtube.com/watch?v=kISsmyiBUgM")
  
  resources :uploads
  post 'question/:par_id/attachment' => 'uploads#create', defaults: {par_type: 1}, as: 'question_attachment'
  post 'idea/:par_id/attachment' => 'uploads#create', defaults: {par_type: 3}, as: 'idea_attachment'
  post 'comment/:par_id/attachment' => 'uploads#create', defaults: {par_type: 22}, as: 'comment_attachment'
  post 'uploads/:id/destroy' => 'uploads#destroy', as: 'attachment_destroy'

  resources :idea_ratings

  resources :idea_versions

  resources :ideas
  
  get 'tour' => 'Welcome#tour', as: 'welcome_tour'

  get 'teams(/:team_id)/setup' => 'teams#setup_form', :as => 'setup_team_form'
  match 'teams(/:team_id)/update_setup' => 'teams#update_setup', :via => [:put, :post], :as => 'setup_team_post'

  match 'plan/get_templates' => 'plan#get_templates'
  match 'idea/get_templates' => 'plan#get_ideas_templates'
  match 'plan/checklist' => 'plan#checklist', :as=> 'checklist'
  
  get 'proposal_vote' => 'proposal#vote', :as => 'proposal_vote'
  post 'proposal_vote' => 'proposal#vote_save', :as => 'proposal_vote'
  
  get 'live/channel_monitor' => 'ce_live#channel_monitor', :as => 'live_channel_monitor'
  match 'jug' => 'chat#jug'
  match "juggernaut_xmit" => 'chat#juggernaut_xmit', :as => 'juggernaut_xmit'

  get 'live/home' => 'ce_live#live_home', :as => 'live_home'
  get 'live/:event_id/dispatcher' => 'ce_live#dispatcher', :as => 'live_dispatcher'
  get 'live/jug_id' => 'ce_live#record_juggernaut_id'
  get 'live/scribe' => 'ce_live#scribe', :as => 'live_scribe'
  get 'live/ltp_to_jug' => 'ce_live#ltp_to_jug'
  get 'live/lt_to_jug' => 'ce_live#lt_to_jug'
  get 'live/ut_to_jug' => 'ce_live#ut_to_jug'
  get 'live/group' => 'ce_live#group'
  get 'live/theme' => 'ce_live#theme'
  get 'live/get_templates' => 'ce_live#get_templates'
  get 'live/test' => 'ce_live#session_test'
  #post 'live/:channel/post_tp' => 'ce_live#post_talking_point_from_group', :as => 'post_live_tp'
  post 'live/post_tp' => 'ce_live#post_talking_point_from_group', :as => 'post_live_tp'
  post 'live/post_theme' => 'ce_live#post_theme_update', :as => 'post_live_theme'
  post 'live/test_ids' => 'ce_live#get_tp_test_ids', :as => 'live_test_ids'
  post 'live/theme/edit' => 'ce_live#edit_theme', :as => 'live_theme_edit'

  get 'live/:session_id/session_themes' => 'ce_live#session_themes', :as => 'live_session_themes'
  get 'live/:session_id/session_full_data' => 'ce_live#session_full_data', :as => 'live_session_full_data'
  get 'live/:session_id/session_allocation_options' => 'ce_live#session_allocation_options', :as => 'live_session_allocation_options'
  get 'live/:session_id/session_allocation_voting' => 'ce_live#session_allocation_voting', :as => 'live_session_allocation_voting'
  post 'live/:session_id/allocate' => 'ce_live#allocate_save', :as => 'live_allocate_save'
  get 'live/:session_id/session_allocation_results' => 'ce_live#session_allocation_results', :as => 'live_session_allocation_results'
  get 'live/:session_id/session_allocations' => 'ce_live#voter_session_allocations', :as => 'live_voter_session_allocations'
  get 'live/:session_id/vote_results' => 'ce_live#vote_results', :as => 'live_vote_results'
  
  get 'proposal/:team_id/print' => 'proposal#print', :as => 'print_proposal'
  get 'proposal/list' => 'proposal#list', :as => 'proposal_list'
  
  get 'live/:event_id/event_setup' => 'ce_live#event_setup', :as => 'live_event_setup'
  get 'live/:session_id/micro_themer' => 'ce_live#micro_themer', :as => 'live_micro_themer' 
  get 'live/:session_id/macro_themer' => 'ce_live#macro_themer', :as => 'live_macro_themer' 
  get 'live/:session_id/macro_macro_themer' => 'ce_live#macro_macro_themer', :as => 'live_macro_macro_themer' 
  get 'live/:session_id/theme_final_edit' => 'ce_live#theme_final_edit', :as => 'live_theme_final_edit'
  get 'live/:session_id/table' => 'ce_live#table', :as => 'live_table'
  get 'live/:session_id/group_tp/:group_id' => 'ce_live#group_talking_points', :as => 'live_group_talking_points'
  get 'live/:session_id/themer_themes/:themer_id' => 'ce_live#themer_themes', :as => 'live_themer_themes'
  get 'live/:session_id/report' => 'ce_live#session_report', :as => 'session_report'
  get 'live/:session_id/prioritize' => 'ce_live#prioritize', :as => 'live_prioritize'
  get 'live/:event_id/observer' => 'ce_live#observer', :as => 'live_observer'
  get 'live/:event_id/add_session(/:id)' => 'ce_live#add_session_form', :as=> 'add_live_session'
  match 'live/:event_id/add_session(/:id)' => 'ce_live#add_session_form', :as=> 'edit_live_session'
  match 'live/:event_id/post_session(/:id)' => 'ce_live#add_session_post', :via=>[:put,:post], :as=> 'post_live_session'
  match 'live/:event_id/delete_session(/:id)' => 'ce_live#delete_session_post', :via=>[:put,:post], :as=> 'delete_live_session'
  get 'live/:session_id/stream' => 'ce_live#stream', as: 'live_stream'
  get 'live/:session_id/stream_jug' => 'ce_live#stream_juggernaut_messages', as: 'live_stream_jug'
  
  get 'live/:event_id/add_node(/:id)' => 'ce_live#add_node_form', :as=> 'add_live_node'
  match 'live/:event_id/add_node(/:id)' => 'ce_live#add_node_form', :as=> 'edit_live_node'
  match 'live/:event_id/post_node(/:id)' => 'ce_live#add_node_post', :via=>[:put,:post], :as=> 'post_live_node'
  match 'live/:event_id/delete_node(/:id)' => 'ce_live#delete_node_post', :via=>[:put,:post], :as=> 'delete_live_node'
  
  post 'live/:event_id/clear_event_test_data' => 'ce_live#clear_event_test_data', as: 'clear_event_test_data'
  post 'live/:event_id/exit_event_test_mode' => 'ce_live#exit_event_test_mode', as: 'exit_event_test_mode'
  
  match "live/chat" => 'ce_live#send_chat_message', :as => 'live_chat'
  get "live/sign_in_form" => 'ce_live#sign_in_form', :as => 'live_sign_in'
  match "live/sign_out" => 'ce_live#sign_out', :as => 'sign_out'
  
  get 'theme/:theme_id/details', to: 'ce_live#theme_details', as: 'view_theme_details'
  get 'theme/:theme_id/edit_theme', to: 'ce_live#edit_theme', as: 'edit_live_theme'
  post 'theme/:theme_id/edit_theme', to: 'ce_live#edit_theme_post', as: 'edit_live_theme'
  
  
  
  match "chat" => 'chat#send_chat_message', :as => 'chat'

  get "chat_form/:team_id" => 'chat#chat_form', :as => 'chat_form'
  get 'test_insert'=>'chat#test_insert'
  
  get "profile/index"

  get "profile/upload_photo"

  get "profile/my_teams"

  get "sign_in/sign_in_form", :as => 'sign_in'
  
  get ":controller/sign_in_form", :action => 'sign_in_form', :as => 'sign_in_all'
  
  post ":controller/sign_in_post", :action => 'sign_in_post', :as => 'sign_in_post'
  post ":controller/temp_join_save_email", :action => 'temp_join_save_email', :as => 'temp_join_save_email'
  
  get "sign_in/sign_in"

  get "sign_in/sign_out", :as=>'sign_out'

  get "sign_in/reset_password_form", :as => 'reset_password_form'
  post "sign_in/reset_password_post", :as => 'reset_password_post'

  get "sign_in/password_reset_form", :as => 'password_reset_form'
  post "sign_in/password_reset_post", :as => 'password_reset_post'
  
  get "sign_in/change_password"

  get "registration/register"

  get "registration/request_confirmation_email"

  get "registration/confirm_registration"

  get "plan/suggest_new_idea", :as => 'suggest_new_idea'
  
  match "plan/:team_id/submit", :to => 'plan#submit_proposal', :as => 'submit_proposal'
  
  post "plan/submit_proposal_idea", :as => 'submit_proposal_idea'
  
  get 'plan/review_proposal_idea/:id', :controller => 'plan', :action => 'review_proposal_idea', :requirements => { :id => /\d+/ }
  
  post "plan/approve_proposal_idea", :controller => 'plan', :action => 'approve_proposal_idea'
  
  get 'plan/:team_id/edit_summary', :to => 'teams#edit_summary_form', :as => 'edit_plan_summary'
  match 'plan/:team_id/edit_summary', :to => 'teams#edit_summary_post', :via => [:put, :post], :as => 'edit_plan_summary'

  match 'endorsements/:team_id/add', :to => 'endorsements#add_endorsement', :via => [:put, :post], :as => 'add_plan_endorsement'
  post 'endorsements/:team_id/delete', :to => 'endorsements#delete', :as => 'delete_plan_endorsement'
  post 'endorsements/:team_id/edit', :to => 'endorsements#edit', :as => 'edit_plan_endorsement'
  match 'endorsements/:team_id/update', :to => 'endorsements#update', :via => [:put, :post], :as => 'update_plan_endorsement'


  match 'idea/:question_id/add', :to => 'ideas#create', :via => [:put, :post], :as => 'add_idea'
  post 'idea/:question_id/delete', :to => 'ideas#destroy', :as => 'delete_idea'
  post 'idea/:question_id/edit', :to => 'ideas#edit', :as => 'edit_idea'
  match 'idea/:question_id/update', :to => 'ideas#update', :via => [:put, :post], :as => 'update_idea'
  get 'idea/:idea_id/details', to: 'ideas#view_idea_details', as: 'view_idea_details'
  post 'idea/:idea_id/add_comment', to: 'ideas#add_comment', as: 'add_idea_comment'
  post 'idea/:idea_id/idea_order', to: 'ideas#theme_ideas_order', as: 'theme_ideas_order'
  post 'idea/:idea_id/create_theme', to: 'ideas#create_theme', as: 'create_theme'
  post 'idea/:idea_id/remove_from_parent', to: 'ideas#remove_from_parent', as: 'remove_from_parent'
  get 'idea/:idea_id/edit_theme', to: 'ideas#edit_theme', as: 'edit_theme'
  post 'idea/:idea_id/edit_theme', to: 'ideas#edit_theme_post', as: 'edit_theme'
  post 'idea/:idea_id/remove_theme', to: 'ideas#remove_theme', as: 'remove_theme'
  get 'plan/:question_id/theme_final_edit', to: 'ideas#theme_final_edit', as: 'theme_final_edit'
  post 'idea/:idea_id/visbility', to: 'ideas#idea_visbility', as: 'idea_visbility'
  get 'idea/:question_id/theme_summary', to: 'ideas#theme_summary', as: 'theme_summary'
  get 'idea/:question_id/wall', to: 'ideas#question_post_its_wall', as: 'question_post_its_wall'
  
  get 'idea/:team_id/team_edit', to: 'ideas#team_edit', as: 'team_edit'
  post 'idea/:team_id/team_edit', to: 'ideas#team_edit_post', as: 'team_edit'
  
  post 'idea/rating', to: 'idea_ratings#update_rating', as: 'update_idea_rating'
	
  get 'idea/:question_id/theme_page', to: 'ideas#theming_page', as: 'theme_question_ideas'

  get 'tos', to: 'welcome#terms_of_service', as: 'tos'

  get 'plan/:team_id/new_content(/:time_stamp)' => 'plan#summary', :as => 'new_content'

  #match 'plan/:id', :controller => 'plan', :action => 'index', :requirements => { :id => /\d+/ }
  match 'plan/:team_id', :to => 'plan#summary', :requirements => { :team_id => /\d+/ }, :as => 'plan'
  match 'proposal/:team_id', :to => 'plan#summary', :requirements => { :team_id => /\d+/ }, :as=> 'proposal'


  match "/idea/:id" => redirect("/plan/%{id}"), :requirements => { :id => /\d+/ }
  match "/idea/bsd/:id" => redirect("/questions/%{id}/worksheet"), :requirements => { :id => /\d+/ }
  match "/idea/index/:id" => redirect("/plan/%{id}"), :requirements => { :id => /\d+/ }

  match "questions/:question_id/curate_tps" => "questions#curate_tps", :as => :curate_question_tps  
  
  post "questions/:question_id/what_do_you_think", :to => "questions#what_do_you_think", :as => 'what_do_you_think'
  get "questions/:question_id/what_do_you_think", :to => "questions#what_do_you_think_form", :as => 'what_do_you_think'
  
  post "questions/:question_id/add_talking_point", :to => "questions#add_talking_point", :as => 'add_talking_point'
  
  get "questions/:question_id/summary" => "questions#summary", :as => :question_summary
  get "questions/:question_id/worksheet" => "questions#worksheet", :as => :question_worksheet
  get "questions/:question_id/new_talking_points" => "questions#new_talking_points", :as => :question_new_talking_points
  get "questions/:question_id/all_talking_points" => "questions#all_talking_points", :as => :question_all_talking_points

  get "questions/:question_id/old_data" => "questions#worksheet", :as => :question_old_data

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
  post "questions/:question_id/add_comment", :to => 'questions#add_comment', :as => 'add_question_comment'

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
  match 'welcome' => redirect('/home')
  get 'contact_us' => 'welcome#contact_us', :as=>'ce_contact_us'
  post 'contact_us' => 'welcome#contact_us_post', :as=>'ce_contact_us_post'
  get 'admin' => 'admin#index', :as=>'admin'
  match 'admin/:action' => 'admin'
  match 'welcome/:action' => 'welcome'

  get 'members/new_profile' => 'members#new_profile_form', :as=>'new_profile_form'
  match 'members/new_profile' => 'members#new_profile_post', :via => [:put, :post], :as=>'new_profile_post'
  get 'members/:ape_code/edit_profile' => 'members#edit_profile_form', :as=>'edit_profile_form'
  match 'members/:ape_code/edit_profile' => 'members#edit_profile_post', :via => [:put, :post], :as=>'edit_profile_post'
  get 'members/:ape_code/profile' => 'members#display_profile', :as=>'display_profile'
  match 'members/:ape_code/photo' => 'members#upload_member_photo', :via => [:put, :post], :as=>'upload_member_photo'

  get 'members/invite(/:team_id)' => 'members#invite_friends_form', :as => 'invite_friends_form'
  match 'members/invite/:team_id/preview' => 'members#invite_friends_preview', :as => 'invite_friends_preview'
  post 'members/invite/:team_id/send' => 'members#invite_friends_send', :as => 'invite_friends_send'
  get 'members/acknowledge_invite_request' => 'members#acknowledge_invite_request', :as => 'invite_friends_acknowledge'

  get 'members/request_new_access_code' => 'members#request_new_access_code', :as => 'request_new_access_code'
  post 'members/send_new_access_code' => 'members#send_new_access_code', :as => 'send_new_access_code'


  match 'notification(/:team_id)/settings' => 'notification#settings_form', :as => 'notification_settings_form'
  match 'notification/:team_id/update_settings' => 'notification#update_notification_settings', :via=>[:put, :post], :as => 'notification_settings_post'
  get 'notification/unsubscribe' => 'notification#unsubscribe', :as => 'unsubscribe'
  
  get 'notification/follow_initiative_form' => 'notification#follow_initiative_form', :as => 'follow_initiative_form'
  post 'notification/follow_initiative_post' => 'notification#follow_initiative_post', :as => 'follow_initiative_post'
  
  post 'initiatives/:initiative_id/join' => 'initiatives#join', :as => 'join_initiative'

  match 'plan/:team_id/proposal_pic(/:pic_id)' => 'plan#proposal_pic', :as => 'proposal_pic'

  match 'subscribe' => 'welcome#subscribe'
  get 'get_started' => 'welcome#get_started'
  post 'get_started' => 'welcome#get_started_post'

  get 'short_help' => 'help#short_help'
  get 'visual_help' => 'help#visual_help'
  get 'help' => 'help#help_page', as: 'help'  
  get 'help_topic' => 'help#help_topic'  
  get 'help_develop' => 'help#help_develop_proposal'
  get 'help_quick_instructions' => 'help#quick_instructions_pi'
  get 'help_answer_question' => 'help#help_answer_question'
  get 'help_curate_show' => 'help#help_curate_show'
  
  get 'help_endorse' => 'help#help_endorse_proposal'

  get 'admin/team/:team_id/stats' => 'admin#team_stats', :as => 'team_stats'
  get 'admin/team/:team_id/team_participant_stats' => 'admin#team_participant_stats', :as => 'team_participant_stats'
  get 'admin/team/:team_id/team_participant_stats_email' => 'admin#team_participant_stats_email', :as => 'team_participant_stats_ermail'

  get 'test' => 'plan#test'
  
  
  get 'notification/display_immediate' => 'notification#display_immediate'
  get 'notification/send_immediate' => 'notification#send_immediate'
  get 'notification/display_periodic' => 'notification#display_periodic'
  get 'notification/send_periodic' => 'notification#send_periodic'
  
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
  #resources :teams
  #resources :initiatives


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

  match ':controller/:action/:id'
  match ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  
    
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
