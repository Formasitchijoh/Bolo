class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def login
    email = params[:email]
    pwd = params[:password]
    render json: { email:, pwd: }
  end

  def getname
    render json: { name: "Hello World" }
  end
end
