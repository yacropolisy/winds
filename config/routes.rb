Rails.application.routes.draw do
  get 'home/st'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :home
  root to: 'home#index'
  get 'board' => 'home#board'
end
