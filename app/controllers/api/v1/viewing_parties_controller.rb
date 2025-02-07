class Api::V1::ViewingPartiesController < ApplicationController
  def create    
    inviteesArray = [];
    viewing_party = ViewingParty.new(viewing_party_params)
    movie_runtime = ViewingPartyGateWay.get_movie_runtime(viewing_party.movie_id)

    viewing_party_duration = (viewing_party.end_time.to_i - viewing_party.start_time.to_i) / 60
    
    if viewing_party.end_time < viewing_party.start_time
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Party end time cannot be before the start time", 400)), status: :bad_request
    end

    if viewing_party_duration < movie_runtime
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Party duration cannot be less than movie runtime", 422)), status: :unproccessable_entity
    end
    
    if viewing_party.save
      if params[:invitees].present?
        host = params[:invitees].first

        if User.exists?(id: host)
          UserViewingParty.create(user_id: host, viewing_party_id: viewing_party.id, host: true)
        end

        params[:invitees].map do |invitee|
          inviteeInfo = {};

          if invitee == host
            next
          end

          viewer = User.find_by(id: invitee)

          if viewer
            UserViewingParty.create(user_id: viewer.id, viewing_party_id: viewing_party.id, host: false)

            inviteeInfo[:id] = viewer.id
            inviteeInfo[:name] = viewer.name
            inviteeInfo[:username] = viewer.username

            inviteesArray.push(inviteeInfo)
          end
        end
      else 
        inviteesArray = [];
      end
      render json: ViewingPartySerializer.new(viewing_party), status: :created
    else
      render json: { message: viewing_party.errors.full_messages[0], status: 422 }
    end
  end

  private

  def viewing_party_params
    params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, invitees: [])
  end
end
