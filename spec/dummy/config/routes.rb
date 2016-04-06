Rails.application.routes.draw do
  mount StatusPage::Engine => '/health'
end
