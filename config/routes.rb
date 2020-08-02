Rails.application.routes.draw do

  get '/confirm/:id', to: 'posts#confirm', as: :confirm
  resources :posts, only: %i(create edit update) do
  end
  root 'posts#new'

end
