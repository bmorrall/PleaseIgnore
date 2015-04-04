Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: 'users/passwords',
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  resource :dashboard, only: [:show]

  namespace :users do
    resources :accounts, only: :destroy do
      post :sort, on: :collection
    end
    resources :versions, only: [:index]
  end

  resource :contact, only: [:show, :create] do
    get :thank_you
  end

  # Utility Methods
  namespace :utils do
    get 'safe_permalink', to: 'safe_permalink#create'
  end

  # Admin Engines
  authenticate :user, ->(u) { u.has_role? :admin } do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  # HighVoltage Pages
  get '/home', to: redirect('/')
  get '/*id' => 'pages#show', as: :page, format: false
  root to: 'pages#show', id: 'home'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

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
