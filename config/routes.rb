Rails.application.routes.draw do
  post 'agreement_letters/create'
  get 'agreement_letters/show'

  resources :requests do
    patch 'contact_person' => 'requests#set_contact_person', as: :set_contact_person
    patch 'notes' => 'requests#set_notes', as: :set_notes
  end

  put 'applications/:id/status' => 'application_letters#update_status', as: :update_application_letter_status
  get 'applications/:id/check' => 'application_letters#check', as: :check_application_letter

  resources :participant_groups, only: [:update]

  resources :application_letters, path: 'applications' do
    resources :application_notes,
      only: :create
  end

  get 'events/archive' => 'events#archive', as: :events_archive
  resources :events do
    resources :agreement_letters, only: [:create], shallow: true
    get 'emails' => 'emails#show', as: :email_show
    post 'emails' => 'emails#submit_application_result', as: :email_submit_application_result
    post 'upload_material' => 'events#upload_material', as: :upload_material
    post 'download_material' => 'events#download_material', as: :download_material
    member do
      post 'emails_generic' => 'emails#submit_generic', as: :email_submit_generic
      get 'participants_pdf'
      get 'print_applications'
      get 'print_applications_eating_habits'
      get 'badges'
      post 'badges' => 'events#print_badges', as: :print_badges
      get 'send_participants_email'
    end
  end
  resources :profiles, except: [:index, :destroy]

  devise_scope :user do
    get "/users/sign_up" => redirect("/users/sign_in")
  end
  devise_for :users, :controllers => {:registrations => "users/registrations"}
  resources :users, only: [:index] # index page for devise users
  patch 'users/:id/role' => 'users#update_role', as: :update_user_role
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'application#index'

  get 'imprint' => 'application#imprint', as: :imprint

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'events/:id/participants' => 'events#participants', as: :event_participants
  post 'events/:id/participants/agreement_letters' => 'events#download_agreement_letters', as: :event_download_agreement_letters
  get 'events/:id/accept_all_applicants' => 'events#accept_all_applicants', as: :event_accept_all_applicants

  resources :requests do
    member do
      get :accept
    end
  end

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
