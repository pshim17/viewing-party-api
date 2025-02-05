class Api::V1::MoviesController < ApplicationController
  def index
    conn = Faraday.new(url: "https://api.themoviedb.org/3")
    
    response = conn.get("movie/top_rated") do |faraday|
      faraday.params["api_key"] = Rails.application.credentials.tmdb[:key]
    end
    
    if response.success?
      top_rated_movies = JSON.parse(response.body)["results"].take(20).map do |movie|
        {
          "id": movie["id"],
          "type": "movie",
          "attributes": {
            "title": movie["title"],
            "vote_average": movie["vote_average"]
          } 
        }
      end

      render json: { data: top_rated_movies }, status: :ok
    else
      render json: { error: "Failed to fetch movies" }, status: :bad_gateway
    end
  end
end

