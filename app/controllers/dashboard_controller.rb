class DashboardController < ApplicationController
  before_action :require_login

  def index
    @users = User.all
    render current_user.role
  end
end
