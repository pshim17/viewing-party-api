class ViewingParty < ApplicationRecord
  has_many :create_joined_user_viewing_parties
  has_many :users, through: :create_joined_user_viewing_parties

  validates :name, :start_time, :end_time, :movie_id, :movie_title, presence: true
end

