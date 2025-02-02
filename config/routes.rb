Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :sleep_records, only: [:create, :update, :index]
      resources :follows, only: [:create] do
        delete "/:following_id", to: "follows#delete", on: :collection
      end
      resources :users, only: [] do
        get "/following/sleep_records", to: "users#list_sleep_records_following", on: :collection
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
