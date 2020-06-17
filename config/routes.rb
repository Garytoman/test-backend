Rails.application.routes.draw do
  root "tasks#index"
  resources :tasks

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :tasks, only: [] do
        collection do
          get 'all'
        end
      end
    end
  end
end
