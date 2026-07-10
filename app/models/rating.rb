class Rating < ApplicationRecord
  belongs_to :job
  belongs_to :technician
  belongs_to :customer
  validates :star, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
end
