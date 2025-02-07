class Api::V1::MoviesController < ApplicationController
  def index    
    if response.success?
      top_rated_movies = MovieGateway.get_top_rated_movies
      render json: { data: top_rated_movies }, status: :ok
    end
  end

  def search 
    conn = Faraday.new(url: "https://api.themoviedb.org/3")
    query = params[:query]

    if query.blank?
      return render json: { error: "Please provide a search term" }, status: :bad_request
    end

    response = conn.get("search/movie") do |faraday|
      faraday.params["api_key"] = Rails.application.credentials.tmdb[:key]
      faraday.params["query"] = query
    end
    
    if response.success?
      searched_movies = JSON.parse(response.body)["results"].first(20).map do |movie|
        {
          "id": movie["id"],
          "type": "movie",
          "attributes": {
            "title": movie["title"],
            "vote_average": movie["vote_average"]
          } 
        }
      end
      render json: { data: searched_movies }, status: :ok
    else
      render json: { error: "Failed to fetch movies by search terms." }, status: :bad_gateway
    end
  end
end

