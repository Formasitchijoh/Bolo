class SessionsController < ApplicationController
  before_action :require_guest, only: [ :new, :create ]

  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      tenant = @user.tenant
      if tenant.present?
        session[:company_id] = tenant.companies.first&.id
      end
      redirect_to dashboard_path, notice: "Successful login"
    else
      @login_error = "Invalid email or password."
      render :new, status: :unauthorized
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "You have been logged out."
    redirect_to dashboard_path
  end
end
