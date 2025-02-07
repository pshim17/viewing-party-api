class ViewingPartyGateWay
  def self.get_movie_runtime(movie_id)
    response = conn.get("movie/#{movie_id}") 
    runtime = JSON.parse(response.body)["runtime"]
  end

  private

  def self.conn
    conn = Faraday.new(
      url: 'https://api.themoviedb.org/3',
      params: {api_key: Rails.application.credentials.tmdb[:key]}
    )
  end
end