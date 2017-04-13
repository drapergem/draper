Dummy::Application.routes.draw do
  scope "(:locale)", locale: /en|zh/ do
    resources :posts, only: [:show] do
      get "mail", on: :member
    end

    resources :categories, only: [:show]
  end

  devise_for :users, :admins if defined?(Devise)
end
