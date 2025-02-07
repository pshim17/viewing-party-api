class Api::V1::MoviesController < ApplicationController
  def index    
    top_rated_movies = MovieGateway.get_top_rated_movies
    render json: MovieSerializer.serialize_movie(top_rated_movies)
  end

  def search 
    search_term = params[:query]
    search_movies = MovieGateway.get_movie_by_search_term(search_term)
    render json: MovieSerializer.serialize_movie(search_movies)
  end
end

