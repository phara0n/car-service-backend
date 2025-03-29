Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/login', to: 'auth#login'
      get 'auth/verify', to: 'auth#verify'
      
      # Admin routes
      namespace :admin do
        resources :users, only: [:index, :show, :create, :update, :destroy]
      end
      
      # Shared routes for admin and customer
      resources :customers, only: [:index, :show, :create, :update, :destroy]
      get 'customers/:customer_id/cars', to: 'customers#cars'
      resources :cars, only: [:index, :show, :create, :update, :destroy]
      resources :appointments, only: [:index, :show, :create, :update, :destroy]
      resources :services, only: [:index, :show, :create, :update, :destroy]
      resources :mileage_records, only: [:index, :show, :create, :update, :destroy]
      resources :service_schedules, only: [:index, :show, :create, :update, :destroy]
      
      # Service prediction routes for admin
      get 'service_predictions/due_soon', to: 'service_predictions#service_due_soon'
      get 'service_predictions/cars/:car_id', to: 'service_predictions#car_predictions'
      post 'service_predictions/cars/:car_id/update', to: 'service_predictions#update_predictions'
      
      # Customer Portal routes
      namespace :customer_portal do
        get 'profile', to: 'profile#show'
        put 'profile', to: 'profile#update'
        resources :cars, only: [:index, :show]
        patch 'cars/:id/update_mileage', to: 'cars#update_mileage'
        resources :appointments, only: [:index, :show, :create]
        resources :services, only: [:index, :show]
        resources :mileage_records, only: [:index, :create]
        
        # Service prediction routes
        get 'service_predictions', to: 'service_predictions#index'
        get 'service_predictions/cars/:car_id', to: 'service_predictions#car_predictions'
      end

      # Dashboard routes
      namespace :dashboard do
        get 'stats', to: 'dashboard#stats'
        get 'mileage_trends', to: 'dashboard#mileage_trends'
        get 'service_distribution', to: 'dashboard#service_distribution'
        get 'appointment_distribution', to: 'dashboard#appointment_distribution'
        get 'recent_activity', to: 'dashboard#recent_activity'
        get 'upcoming_appointments', to: 'dashboard#upcoming_appointments'
      end
    end
  end
end
