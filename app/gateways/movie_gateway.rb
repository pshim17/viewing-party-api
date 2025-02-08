class MovieGateway
  def self.get_top_rated_movies
    response = conn.get("movie/top_rated") 
    JSON.parse(response.body)["results"].first(20)
  end

  def self.get_movie_by_search_term(search_term)
    response = conn.get("search/movie") do |faraday| 
      faraday.params["query"] = search_term
    end
    JSON.parse(response.body)["results"].first(20)
  end

  def self.get_movie_details(movie_id)
    details_response = conn.get("movie/#{movie_id}")
    credits_response = conn.get("movie/#{movie_id}/credits")
    reviews_response = conn.get("movie/#{movie_id}/reviews")

    details_json = JSON.parse(details_response.body)
    credits_json = JSON.parse(credits_response.body)
    reviews_json = JSON.parse(reviews_response.body)

    hours = details_json["runtime"] / 60
    minutes = details_json["runtime"] % 60

    {
      data: {
        "id": movie_id,
        "type": "movie",
        "attributes": {
          "title": details_json["original_title"],
          "release_year": details_json["release_date"].split("-")[0],
          "vote_average": details_json["vote_average"],
          "runtime": "#{hours} hour(s), #{minutes} minutes",
          "genres": self.get_genres(details_json),
          "summary": details_json["overview"],
          "cast": self.get_cast(credits_json),
          "total_reviews": reviews_json["total_results"],
          "reviews": self.get_reviews(reviews_json)
        }
      } 
    }
  end

  private

  def self.conn
    conn = Faraday.new(
      url: 'https://api.themoviedb.org/3',
      params: {api_key: Rails.application.credentials.tmdb[:key]}
    )
  end

  def self.get_genres(details_json)
    genres_array = [];
    details_json["genres"].map do |genre|
      genres_array << genre["name"]
    end
    return genres_array
  end

  def self.get_cast(credits_json)
    cast_array = [];
    credits_json["cast"].first(10).map do |cast|
      cast_info = {}
      cast_info["character"] = cast["character"]
      cast_info["actor"] = cast["name"]
      cast_array << cast_info
    end
    return cast_array
  end

  def self.get_reviews(reviews_json)
    reviews_array = []
    reviews_json["results"].map do |result|
      reviews_info = {}
      reviews_info["author"] = result["author"]
      reviews_info["review"] = result["content"].gsub(/\s+/, ' ').strip
      reviews_array << reviews_info
    end
    return reviews_array.first(5)
  end
end