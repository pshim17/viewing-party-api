class ViewingParty < ApplicationRecord
  has_many :user_viewing_parties
  has_many :users, through: :user_viewing_parties

  validates :name, :start_time, :end_time, :movie_id, :movie_title, presence: true
end

