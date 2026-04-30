# config/initializers/session_store.rb (Rails default)
Rails.application.config.session_store :cookie_store,
  key: "bolo_session",
  secure: Rails.env.production?, # Ensures cookies are only sent over HTTPS in production
  httponly: true, # Ensures cookies are not accessible via JavaScript, mitigating XSS attacks
  same_site: :lax # Protects against CSRF attacks by restricting cross-site requests
