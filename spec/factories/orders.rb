FactoryBot.define do
  factory :order do
    school { build :school }
    recipients { [build(:recipient, school: school)] }
    gifts { Order::GIFTS.sample(2) }

    trait :received do
      status { 'ORDER_RECEIVED' }
    end
    trait :shipped do
      status { 'ORDER_SHIPPED' }
    end
    trait :cancelled do
      status { 'ORDER_CANCELLED' }
    end
  end
end
