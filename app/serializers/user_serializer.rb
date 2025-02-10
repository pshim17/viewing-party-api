class UserSerializer
  include JSONAPI::Serializer
  attributes :name, :username, :api_key

  def self.format_user_list(users) { 
    data:
      users.map do |user|
        {
          id: user.id.to_s,
          type: "user",
          attributes: {
            name: user.name,
            username: user.username
          }
        }
      end
    } 
  end
end