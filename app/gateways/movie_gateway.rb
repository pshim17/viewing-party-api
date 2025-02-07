class MovieGateway
  def self.get_top_rated_movies
    response = conn.get("movie/top_rated") 
    JSON.parse(response.body)["results"].first(20)
  end

  def self.get_movie_by_search_term(search_term)
    query = params[:query]
    response = conn.get("search/movie") do |faraday| 
      faraday.params["query"] = search_term
    end
    JSON.parse(response.body)["results"].first(20).map do |movie|
      {
        "id": movie["id"],
        "type": "movie",
        "attributes": {
          "title": movie["title"],
          "vote_average": movie["vote_average"]
        } 
      }  
    end
  end

  private

  def self.conn
    conn = Faraday.new(
      url: 'https://api.themoviedb.org/3',
      params: {api_key: Rails.application.credentials.tmdb[:key]}
    )
  end
end