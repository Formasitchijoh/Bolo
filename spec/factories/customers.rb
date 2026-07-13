FactoryBot.define do
  factory :customer do
    association :user, factory: :customer_user
    status { "good_standing" }
  end
end
