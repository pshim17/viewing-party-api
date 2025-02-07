class InviteeSerializer
  def self.serialize_invitee(invitee)
    {
      id: invitee.id,
      name: invitee.name,
      username: invitee.username
    }
  end
end

