FactoryBot.define do
  factory :recipient do
    school { build :school }
    name { Faker::Name.name }
    email { Faker::Internet.email }
    address { Faker::Address.full_address }
  end
end
