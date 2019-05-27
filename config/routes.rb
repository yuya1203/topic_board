Rails.application.routes.draw do
  get 'entries/create'
  root 'homes#index'
  devise_for :users
  resources :topics, only: [:index, :new, :create, :show] do
    resources :entries
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
