class Api::V1::MoviesController < ApplicationController
  def index     
    conn = Faraday.new(url: "https://api.themoviedb.org/3")
    response = conn.get("movie/top_rated") do |faraday|
      faraday.params["api_key"] = Rails.application.credentials.tmdb[:key]
    end
    
    if response.success?
      top_rated_movies = JSON.parse(response.body)["results"].first(20).map do |movie|
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
      render json: { error: "Failed to fetch top 20 rated movies" }, status: :bad_gateway
    end
  end

  def search 
    require'pry';binding.pry
    conn = Faraday.new(url: "https://api.themoviedb.org/3")
    query = params[:query]

    if query.blank?
      return render json: { error: "Please provide a search term" }, status: :bad_request
    end

    response = conn.get("search/movie") do |faraday|
      faraday.params["api_key"] = Rails.application.credentials.tmdb[:key]
      faraday.params["query"] = query
    end
    
    require'pry';binding.pry

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

