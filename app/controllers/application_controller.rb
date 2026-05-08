class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  protect_from_forgery with: :exception
  helper_method :current_user, :current_company
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

  def current_company
    @current_company ||= Company.find_by(id: session[:company_id])
  end

  def require_company
    redirect_to dashboard_path unless current_company
  end

  def require_customer
    redirect_to dashboard_path unless current_user&.customer?
  end

  def require_technician
    redirect_to dashboard_path unless current_user&.technician?
  end

  def require_dispatcher
    redirect_to dashboard_path unless current_user&.dispatcher?
  end

  def require_company_admin
    redirect_to dashboard_path unless current_user&.company_admin?
  end

  def require_account_owner
    redirect_to dashboard_path unless current_user&.account_owner?
  end

  def require_platform_admin
    redirect_to dashboard_path unless current_user&.platform_admin?
  end
end
