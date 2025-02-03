class Api::V1::UsersController < ApplicationController
  TMDB_MOVIES_API_KEY = 'f984e0a1bf9bb60517d17e2dabb7e731'

  def create
    user = User.new(user_params)
    if user.save
      render json: UserSerializer.new(user), status: :created
    else
      render json: ErrorSerializer.format_error(ErrorMessage.new(user.errors.full_messages.to_sentence, 400)), status: :bad_request
    end
  end

  def index
    connection = Faraday.new(url: 'https://api.themoviedb.org/3')
    response = connection.get("/movie/popular?api_key=#{TMDB_MOVIES_API_KEY}")

    if response.success?
      render json: UserSerializer.format_user_list(User.all)
    else
      render json: { error: "Something went wrong" }, status: 400
    end
  end

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation)
  end
end