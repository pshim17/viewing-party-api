class UserDetailsSerializer
  include JSONAPI::Serializer

  def self.format_user_details_list(viewingPartiesInfo) 
    { 
      data:
      viewingPartiesInfo.map do |info|
          {
            "id": info.id,
            "name": info.name,
            "start_time": format_time(info.start_time),
            "end_time": format_time(info.end_time),
            "movie_id": info.movie_id,
            "movie_title": info.movie_title,
            "host_id": get_viewing_party_hosted_id(info.id)
          }
        end
      }
  end

  def self.get_viewing_party_hosted_id(id)
    UserViewingParty.find_by(viewing_party_id: id, host: true).user_id
  end

  def self.format_time(time)
    time.strftime('%Y-%m-%d %H:%M:%S')
  end
end