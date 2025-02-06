class Api::V1::ViewingPartiesController < ApplicationController
  def create    
    inviteesArray = [];
    viewing_party = ViewingParty.new(viewing_party_params)
    movie_runtime = fetch_movie(viewing_party.movie_id)

    viewing_party_duration = (viewing_party.end_time.to_i - viewing_party.start_time.to_i) / 60
    
    if viewing_party.end_time < viewing_party.start_time
      return render json: { message: "Party end time cannot be before the start time", status: 422 }
    end

    if viewing_party_duration < movie_runtime
      return render json: { message: "Party duration cannot be less than movie runtime", status: 422 }
    end

    if viewing_party.save
      if params[:invitees].present?
        params[:invitees].map do |invitee|
          inviteeInfo = {};

          viewer = User.find_by(id: invitee)

          if viewer
            inviteeInfo[:id] = viewer.id
            inviteeInfo[:name] = viewer.name
            inviteeInfo[:username] = viewer.username

            if !viewing_party.users.include?(viewer)
              inviteesArray.push(inviteeInfo)
            end
          end
        end
      else
        inviteesArray = [];
      end

      render json: { 
        data: {
          "id": viewing_party.id,
          "type": "viewing_party",
          "attributes": {
            "name": viewing_party.name,
            "start_time": viewing_party.start_time,
            "end_time": viewing_party.end_time,
            "movie_id": viewing_party.movie_id,
            "movie_title": viewing_party.movie_title,
            "invitees": inviteesArray
          }
        } 
      }, status: :created
    else
      render json: { message: viewing_party.errors.full_messages[0], status: 422 }
    end
  end

  private

  def viewing_party_params
    params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, invitees: [])
  end

  def fetch_movie(movie_id)
    conn = Faraday.new(url: "https://api.themoviedb.org/3")
    response = conn.get("movie/#{movie_id}") do |faraday|
      faraday.params["api_key"] = Rails.application.credentials.tmdb[:key]
    end

    if response.success?
      movie_runtime = JSON.parse(response.body)["runtime"]
      return movie_runtime
    end
  end
end
