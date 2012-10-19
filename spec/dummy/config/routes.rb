Dummy::Application.routes.draw do
  resources :posts, :only => [:show]
end
