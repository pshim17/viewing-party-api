class User < ApplicationRecord
  has_many :create_joined_user_viewing_parties
  has_many :viewing_parties, through: :create_joined_user_viewing_parties

  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :password, presence: { require: true }
  has_secure_password
  has_secure_token :api_key
end