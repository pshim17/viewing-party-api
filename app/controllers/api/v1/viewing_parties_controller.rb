class Api::V1::ViewingPartiesController < ApplicationController
  def create    
    inviteesArray = [];
    
    viewing_party = ViewingParty.new(viewing_party_params)

    if viewing_party.save
      params[:invitees].map do |invitee|
        require'pry';binding.pry
        inviteeInfo = {};

        viewer = User.find(invitee)

        if viewer
          inviteeInfo[:id] = viewer.id
          inviteeInfo[:name] = viewer.name
          inviteeInfo[:username] = viewer.username
          inviteesArray.push(inviteeInfo)
        end
      end
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
  end

  private

  def viewing_party_params
    params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, invitees: [])
  end
end
