class Api::V1::ViewingPartiesController < ApplicationController
  def create
    host = User.find_by(id: params[:host_id])

    if host.blank?
      render json: { error: "Host was not found" }, status: :not_found 
    end

    viewing_party = ViewingParty.new(viewing_party_params)
    viewing_party.host = host

    require'pry';binding.pry
  end
end
