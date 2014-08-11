DiagramRailsApp::Application.routes.draw do
  get "training/index"
  match "training", :controller => 'training', :action => 'index'

  root :to => "home#index"
  get "admin", :to => "admin/books#index"

  resources :jobs

  resources :book_fragments

  
  modified_config = ActiveAdmin::Devise.config.clone
  modified_config[:controllers][:registrations] = 'registrations'
  modified_config[:path] = 'auth'
  devise_for :users, modified_config

  ActiveAdmin.routes(self)

  #devise_for :admin_users, ActiveAdmin::Devise.config, ActiveAdmin::Devise.config

  get "image_book/get_xml_with_descriptions"
  get "image_book/get_daisy_with_descriptions"
  get "image_book/process"
  get "image_book/image_check"
  get "image_book/download_with_descriptions", :as => :download_with_descriptions
  get "image_book/poll_file_with_descriptions", :as => :poll_file_with_descriptions
  
  post "image_book/submit_to_get_descriptions"
  post "image_book/check_image_coverage"

  post "upload_book/submit"
  get "upload_book/upload"

  get "edit_book/content"
  get "edit_book/local_file"
  get "edit_book/s3_file"
  get "edit_book/describe"
  get "edit_book/edit"

  # just to help determine page size limits
  get "edit_book/edit_side_bar_only"
  get "edit_book/edit_content_only"

  get "edit_book/side_bar"
  get "edit_book/book_header"

  get "books/get_books_with_images"
  get "books/get_latest_descriptions"
  get "books/get_approved_book_stats"
  post "books/mark_approved"

  get "api/get_approved_descriptions_and_book_stats"
  get "api/get_approved_book_stats"
  get "api/get_approved_descriptions"
  get "api/get_approved_stats"
  get "api/get_approved_content_models"
  get "api/get_image_approved"

  get "reports/index"
  get "reports/update_book_stats"
  get "reports/describer_list"
  get "reports/view_book"
  match "reports", :controller => 'reports', :action => 'index'

  get "repository/cleanup"
  get "repository/expire_cached"


  resources :users
  resources :dynamic_descriptions
  resources :books
  resources :dynamic_images

  resources :descriptions

  resources :images do
    resources :descriptions
  end

  resources :libraries

  match "book_list", :controller => 'books', :action => 'book_list'
  match "book_list_by_user", :controller => 'books', :action => 'book_list_by_user'
  match "image_book/describe", :controller => 'edit_book', :action => 'describe'
  match "edit_book/help", :controller => 'edit_book', :action => 'help'
  match "edit_book/description_guidance", :controller => 'edit_book', :action => 'description_guidance'
  match "update_descriptions_in_book/upload" => "update_descriptions_in_book#upload", :via => "post"
  match "update_descriptions_in_book" => "update_descriptions_in_book#index", :via => "get"
  match "user/terms_of_service", :controller => 'users', :action => 'terms_of_service'

  match "delete_descriptions_by_id", :controller => "dynamic_descriptions", :action => "delete_descriptions_by_id", :via => "post", :as => 'delete_descriptions_by_id'

  get "home/index"

  # match 'imageDesc' => "dynamic_images#show"
  match "imageDesc", :to => "dynamic_images#show", :via => "get"
  match "imageDescriptions", :to => "dynamic_images#show_history", :via => "get"
  match "imageDesc/dynamic_images/:id", :to => "dynamic_images#update", :via => "post"
  # match "imageDesc/uid/:uid/image_location/:image_location", :to => "dynamic_images#show", :via => "get"
  match "imageDesc", :to => "dynamic_descriptions#create", :via => "post"
  match "imageDesc/mark_all_essential", :to => "dynamic_images#mark_all_essential", :via => "post"

  match "cm/:dynamic_image_id/current.xml", :to => "api#get_image_approved", :via => "get"

  #match "books/mark_approved", :to => "books#mark_approved", :via => "post"

  match "file/*directory/*file", :controller => 'file', :action => 'file'
  match "file/*file", :controller => 'file', :action => 'file'
  match "admin_user_delete", :controller => 'users', :action => 'delete' 
  match "admin_book_delete", :controller => 'books', :action => 'delete'
  match 'dynamic_descriptions_search', :controller => 'dynamic_descriptions', :action => 'search'
  
  match 'dynamic_images_sample_html/:id', :controller => 'dynamic_images', :action => 'category_sample_html_page'
  match 'dyn_desc_history/:image_id', :controller => 'dynamic_descriptions', :action => 'body_history', :as => 'dyn_desc_history'



  # match 'imageDesc/uid/:uid => 'dynamic_image#show'

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
  

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
