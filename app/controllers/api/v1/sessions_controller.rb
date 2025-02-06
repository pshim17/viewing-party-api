class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(username: params[:username])
    
    if user && user.authenticate(params[:password])
      render json: UserSerializer.new(user)
    else
      render json: ErrorSerializer.format_error(ErrorMessage.new("Invalid login credentials", 401)), status: :unauthorized
    end
  end
end