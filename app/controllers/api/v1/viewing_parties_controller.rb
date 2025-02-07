require './app/gateways/viewing_party_gateway'

class Api::V1::ViewingPartiesController < ApplicationController
  def create    
    inviteesArray = [];
    viewing_party = ViewingParty.new(viewing_party_params)
    movie_runtime = ViewingPartyGateway.get_movie_runtime(viewing_party["movie_id"])

    viewing_party_duration = (viewing_party.end_time.to_i - viewing_party.start_time.to_i) / 60
    
    if viewing_party.end_time < viewing_party.start_time
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Party end time cannot be before the start time", 400)), status: :bad_request
    end

    if viewing_party_duration < movie_runtime
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Party duration cannot be less than movie runtime", 422)), status: :unprocessable_entity
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
      end
      render json: ViewingPartySerializer.new(viewing_party), status: :created
    else
      render json: { message: viewing_party.errors.full_messages[0], status: 422 }
    end
  end

  def invitees
    viewing_party = ViewingParty.find_by(id: params[:viewing_party_id].to_i)
    invitee_id = params[:invitees_user_id]
    new_invitee = User.find(invitee_id)

    if viewing_party.nil?
      return render json: { error: "Viewing party not found" }, status: :not_found
    end
  
    if new_invitee.nil?
      return render json: { error: "User not found" }, status: :not_found
    end

    if viewing_party
      if viewing_party.users.exists?(id: new_invitee.id)
        render json: { message: viewing_party.errors.full_messages[0], status: 422 }
      else
        UserViewingParty.create(user_id: new_invitee.id, viewing_party_id: viewing_party.id, host: false)
        serialized_invitee = InviteeSerializer.serialize_invitee(new_invitee)
        render json: ViewingPartySerializer.new(viewing_party), status: :created
      end
    end
  end

  private

  def viewing_party_params
    params.require(:viewing_party).permit(:name, :start_time, :end_time, :movie_id, :movie_title, invitees: [])
  end
end
