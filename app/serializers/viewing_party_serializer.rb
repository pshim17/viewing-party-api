class ViewingPartySerializer
  include JSONAPI::Serializer
  attributes :name, :start_time, :end_time, :movie_id, :movie_title

  attribute :start_time do |object|
    object.start_time.strftime('%Y-%m-%d %H:%M:%S')
  end

  attribute :end_time do |object|
    object.end_time.strftime('%Y-%m-%d %H:%M:%S')
  end

  attribute :invitees do |object|
    object.users.map do |user|
      {
        id: user.id,
        name: user.name,
        username: user.username
      }
    end
  end
end