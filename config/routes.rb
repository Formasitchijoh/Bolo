Rails.application.routes.draw do
  get  "register"  => "registrations#new"
  post "register"  => "registrations#create"

  get    "login"   => "sessions#new"
  post   "login"   => "sessions#create"
  delete "logout"  => "sessions#destroy"
  get "up" => "rails/health#show", as: :rails_health_check
end
