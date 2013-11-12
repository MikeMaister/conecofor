ActionController::Routing::Routes.draw do |map|
  #map.signup 'signup', :controller => 'users', :action => 'new'
  map.signup 'signup', :controller => 'users', :action => 'new_rilevatore'
  map.signup_admin 'signup_admin', :controller => 'users', :action => 'new_admin'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.login 'login', :controller => 'sessions', :action => 'new'

  map.validate_user '/validate_user/:activation_code', :controller => 'users', :action => 'validate_user'
  map.pass_res_edit 'password_help', :controller => 'users', :action => 'pass_res_edit'
  map.send_psw_reset 'password_help/send', :controller => 'users', :action => 'send_psw_reset'
  map.reset_psw '/reset_psw_form/:psw_reset', :controller => 'users', :action => 'reset_psw'
  map.set_psw 'reset_psw', :controller => 'users', :action => 'set_psw'
  map.edit_info 'edit', :controller => 'users', :action => 'edit_info'
  map.update_info 'up', :controller => 'users', :action => 'update_info'


  map.contacts 'contacts', :controller => 'home', :action => 'contacts'
  map.help 'help', :controller => 'home', :action => 'help'
  map.download_admin_manual 'admin_manual', :controller => 'home', :action => 'download_admin_manual'
  map.download_rilevatore_manual 'rilevatore_manual', :controller => 'home', :action => 'download_rilevatore_manual'

  map.download_ss '/download/ss/:id', :controller => 'survey_sheet', :action => 'download_survey_sheet'

  map.resources :sessions

  map.resources :users

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "home"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
