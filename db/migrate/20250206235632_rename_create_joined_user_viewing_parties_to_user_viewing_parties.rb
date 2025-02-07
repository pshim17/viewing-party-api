class RenameCreateJoinedUserViewingPartiesToUserViewingParties < ActiveRecord::Migration[7.1]
  def change
    rename_table :create_joined_user_viewing_parties, :user_viewing_parties
  end
end
