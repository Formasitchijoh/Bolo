Rails.application.routes.draw do
  root "sessions#new"
  get  "register"  => "registrations#new"
  post "register"  => "registrations#create"

  get    "login"   => "sessions#new"
  post   "login"   => "sessions#create"
  delete "logout"  => "sessions#destroy"

  get "dashboard" => "dashboard#index"

  # Jobs Routes
  get  "jobs"         => "jobs#index",  as: :jobs
  get  "jobs/new"     => "jobs#new",    as: :new_job
  post "jobs"         => "jobs#create"
  get  "jobs/:id"     => "jobs#show",   as: :job

  # Technician Profile
  get   "technician/profile" => "technician_profiles#edit",   as: :edit_technician_profile
  patch "technician/profile" => "technician_profiles#update", as: :technician_profile

  # Assignment Routes
  get "assignments" => "assignments#index"
  patch "assignments/:id/accept" => "assignments#accept", as: :accept_assignment
  patch "assignments/:id/reject" => "assignments#reject", as: :reject_assignment
  patch "assignments/:id/en_route" => "assignments#en_route",  as: :en_route
  patch "assignments/:id/arrived" => "assignments#arrived",  as: :arrived

  # Work Orders Routes
  get "work_orders" => "work_orders#index"
  get "work_orders/:id" => "work_orders#show", as: :work_order_details
  patch "work_orders/:id/start" => "work_orders#work_order_started", as: :start_work_order
  patch "work_orders/:id/complete" => "work_orders#work_order_completed", as: :complete_work_order

  # Line Items — nested under work orders so work_order_id is always in params
  get    "work_orders/:work_order_id/line_items"  => "line_items#index",     as: :line_items
  get    "work_orders/:work_order_id/line_items/new"  => "line_items#new",     as: :new_line_item
  post   "work_orders/:work_order_id/line_items"      => "line_items#create",  as: :create_new_line_item
  delete "work_orders/:work_order_id/line_items/:id"  => "line_items#destroy", as: :line_item_destroy
  patch "work_orders/:id/hold"          => "work_orders#hold",          as: :hold_work_order
  patch "work_orders/:id/resume"        => "work_orders#resume",        as: :resume_work_order
  patch "work_orders/:id/submit_quote"  => "work_orders#submit_quote",  as: :submit_quote
  patch "work_orders/:id/approve_quote" => "work_orders#approve_quote", as: :approve_quote
  patch "work_orders/:id/reject_quote"  => "work_orders#reject_quote",  as: :reject_quote


  get "up" => "rails/health#show", as: :rails_health_check
end
