FactoryBot.define do
  factory :assignment do
    association :job
    association :technician
    status       { "assigned" }
    claim_window { 15.minutes.from_now }
  end
end
