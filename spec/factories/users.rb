FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name  { "Doe" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    status { "active" }
    role { "customer" }

    factory :customer_user do
      role { "customer" }
    end

    factory :technician_user do
      role { "technician" }
    end
  end
end
