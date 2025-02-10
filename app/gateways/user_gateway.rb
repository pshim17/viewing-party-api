class UserGateway
  def self.get_viewing_parties_invited(user_id)
    viewing_party_invited = [];
    viewing_party_hosted = [];

    UserViewingParty.where(user_id: user_id).map do |party|
      viewing_party = ViewingParty.find_by(id: party.viewing_party_id)

      if party.host
        viewing_party_hosted.push(viewing_party)
      else
        viewing_party_invited.push(viewing_party)
      end
    end
      {
        "viewing_parties_hosted": UserDetailsSerializer.format_user_details_list(viewing_party_hosted), 
        "viewing_parties_invited": UserDetailsSerializer.format_user_details_list(viewing_party_invited) 
      }
  end
end