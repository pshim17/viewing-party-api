class User < ApplicationRecord
  has_many :hosted_parties
  has_many :viewing_party_users
  has_many :viewing_parties, through: :viewing_party_users

  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: { require: true }
  has_secure_password
  has_secure_token :api_key
end