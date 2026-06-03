class RegistrationsController < ApplicationController
  # before_action is a controller calllback that runs before specified actions
  # In this case, it ensured that only guests (Users who are not logged in) can access the new and create actions
  before_action :require_guest, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      destination = @user.technician? ? edit_technician_profile_path : dashboard_path
      redirect_to destination, notice: "Welcome to Bolo"
    else
      render :new, status: :unprocessable_entity
    end
  end
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :status, :password, :password_confirmation)
  end
end
