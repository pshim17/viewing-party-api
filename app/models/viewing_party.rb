class ViewingParty < ApplicationRecord
  has_many :create_joined_user_viewing_parties
  has_many :users, through: :create_joined_user_viewing_parties
end

