FactoryBot.define do
  factory :technician do
    association :user, factory: :technician_user
    status   { "verified" }
    verified { true }
  end
end
