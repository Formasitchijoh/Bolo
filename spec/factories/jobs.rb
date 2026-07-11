FactoryBot.define do
  factory :job do
    association :customer
    association :job_category
    title           { "Fix leaking pipe" }
    details         { "The kitchen pipe has been leaking for two days." }
    price_range_min { 5000 }
    price_range_max { 15000 }
    status          { "available" }
    latitude        { 3.848 }
    longitude       { 11.502 }
  end
end
