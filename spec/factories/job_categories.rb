FactoryBot.define do
  factory :job_category do
    sequence(:name) { |n| "Category #{n}" }
  end
end
