require './app/gateways/viewing_party_gateway'

class Api::V1::ViewingPartiesController < ApplicationController
  def create
    required_fields = [:name, :start_time, :end_time, :movie_id, :movie_title]
    missing_fields = []
    inviteesArray = [];

    viewing_party = ViewingParty.new(viewing_party_params.except(:invitees))
    movie_runtime = ViewingPartyGateway.get_movie_runtime(viewing_party["movie_id"])

    missing_fields = required_fields.select { |field| params[field].blank? }
    if missing_fields.any?
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Missing required field(s): #{missing_fields.join(', ')}", 400)), status: :bad_request
    end

    start_time = DateTime.parse(params[:start_time]) 
    end_time = DateTime.parse(params[:end_time])

    viewing_party_duration = viewing_party_duration(viewing_party)

    if viewing_party.end_time < viewing_party.start_time
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Party end time cannot be before the start time", 400)), status: :bad_request
    end

    if viewing_party_duration < movie_runtime
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Party duration cannot be less than movie runtime", 422)), status: :unprocessable_entity
    end
    
    if viewing_party.save
      if params[:invitees].present?
        handle_invitees(params[:invitees], viewing_party)
      end
      return render json: ViewingPartySerializer.new(viewing_party), status: :created
    else
      return render json: ErrorSerializer.format_error(ErrorMessage.new(viewing_party.errors.full_messages[0], 422)), status: :unprocessable_entity
    end
  end

  def invitees
    viewing_party = ViewingParty.find_by(id: params[:viewing_party_id].to_i)
    invitee_id = params[:invitees_user_id]
    
    new_invitee = User.find_by(id: invitee_id)
  
    if new_invitee.nil?
      return render json: ErrorSerializer.format_error(ErrorMessage.new("User not found", 422)), status: :unprocessable_entity
    end

    if viewing_party.nil?
      return render json: ErrorSerializer.format_error(ErrorMessage.new("Viewing party not found", 422)), status: :unprocessable_entity
    end

    if viewing_party
      if viewing_party.users.exists?(id: new_invitee.id)
        return render json: { message: "The new invitee was already invited to the viewing party", status: 422 }
      else
        UserViewingParty.create(user_id: new_invitee.id, viewing_party_id: viewing_party.id, host: false)
        serialized_invitee = InviteeSerializer.serialize_invitee(new_invitee)
        return render json: ViewingPartySerializer.new(viewing_party), status: :created
      end
    end
  end

  private

  def viewing_party_params
    params.permit(:name, :start_time, :end_time, :movie_id, :movie_title, invitees: [])
  end

  def viewing_party_duration(viewing_party)
    (viewing_party.end_time.to_i - viewing_party.start_time.to_i) / 60
  end

  def handle_invitees(invitees, viewing_party)
    host = invitees.first
  
    if User.exists?(id: host)
      UserViewingParty.create(user_id: host, viewing_party_id: viewing_party.id, host: true)
    end
  
    invitees.each do |invitee|
      next if invitee == host
  
      viewer = User.all.find_by(id: invitee.to_i)
  
      if viewer
        UserViewingParty.create(user_id: viewer.id, viewing_party_id: viewing_party.id, host: false)
      end
    end
  end
end
