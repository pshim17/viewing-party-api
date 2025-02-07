FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    username { Faker::Internet.username }
    password { Faker::Internet.password }
    password_confirmation { password }
  end
end