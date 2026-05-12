Rails.application.routes.draw do
  root "sessions#new"
  get  "register"  => "registrations#new"
  post "register"  => "registrations#create"

  get    "login"   => "sessions#new"
  post   "login"   => "sessions#create"
  delete "logout"  => "sessions#destroy"

  get "dashboard" => "dashboard#index"

  # Jobs Routes
  get "jobs" => "jobs#index"
  get "jobs/new" => "jobs#new"
  post "jobs" => "jobs#create"

  # Technician Profile
  get   "technician/profile" => "technician_profiles#edit",   as: :edit_technician_profile
  patch "technician/profile" => "technician_profiles#update", as: :technician_profile

  # Assignment Routes
  get "assignments" => "assignments#index"
  patch "assignments/:id/accept" => "assignments#accept", as: :accept_assignment
  patch "assignments/:id/reject" => "assignments#reject", as: :reject_assignment

  get "up" => "rails/health#show", as: :rails_health_check
end
