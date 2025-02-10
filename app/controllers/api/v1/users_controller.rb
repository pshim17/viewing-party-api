class Api::V1::UsersController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      render json: UserSerializer.new(user), status: :created
    else
      render json: ErrorSerializer.format_error(ErrorMessage.new(user.errors.full_messages.to_sentence, 400)), status: :bad_request
    end
  end

  def index
    render json: UserSerializer.format_user_list(User.all)
  end

  def show
    user = User.find_by(id: params["id"])

    if user      
      viewing_parties = UserGateway.get_viewing_parties_invited(user.id)
      
      render json: {
        data: {
          "id": user.id.to_s,
          "type": "user",
          "attributes": {
            "name": user.name,
            "username": user.username,
            "viewing_parties_hosted": viewing_parties[:viewing_parties_hosted][:data],
            "viewing_parties_invited": viewing_parties[:viewing_parties_invited][:data]
          }
        }
      }
    else 
      render json: ErrorSerializer.format_error(ErrorMessage.new("User id is invalid", 404)), status: :not_found
    end
  end

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation)
  end
end