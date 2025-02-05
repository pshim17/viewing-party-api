class ViewingParty < ApplicationRecord
  belongs_to :host
  has_many :viewing_party_users
  has_many :users through: :viewing_party_users
end
