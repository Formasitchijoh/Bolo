FactoryBot.define do
  factory :work_order do
    association :assignment
    status { "arrived" }
    total_paused_seconds { 0 }
  end
end
