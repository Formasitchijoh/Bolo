class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Successful login"
    else
      render :new, status: :unauthorized
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:notice] = "You have been logged out."
    redirect_to dashboard_path
  end
end
