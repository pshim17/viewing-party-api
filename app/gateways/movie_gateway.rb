class MovieGateway
  def self.get_top_rated_movies
    response = conn.get("movie/top_rated") 
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