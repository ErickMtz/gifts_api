FactoryBot.define do
  factory :school do
    name { Faker::University.name }
  end
end
