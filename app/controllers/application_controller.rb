class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  protect_from_forgery with: :exception
  helper_method :current_user
  # Rails automatically:
  # - Generates unique token per session
  # - Includes token in form helpers
  # - Verifies token on non-GET requests
  # - Raises exception if token invalid

  def current_user
    @current_user  ||= User.find_by(id: session[:user_id])
  end

  def require_login
    redirect_to login_path unless current_user
  end
end
