Dummy::Application.routes.draw do
  scope "(:locale)", locale: /en|zh/ do
    resources :posts, only: [:show]
  end
end
