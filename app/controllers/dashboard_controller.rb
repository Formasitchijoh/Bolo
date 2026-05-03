class DashboardController < ApplicationController
  before_action :require_login

  def index
    render current_user.role
  end
end
