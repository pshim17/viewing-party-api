FactoryBot.define do
  factory :viewing_party do
    name { Faker::Movie.title }
    start_time { Faker::Time.forward(days: 30, period: :morning) } 
    end_time { start_time + 5.hours } 
    movie_id { Faker::Number.number(digits: 6) } 
    movie_title { Faker::Movie.title } 
  end
end