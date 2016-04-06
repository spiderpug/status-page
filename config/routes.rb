StatusPage::Engine.routes.draw do
  resources :status do
    collection do
      get :check
    end
  end
end
