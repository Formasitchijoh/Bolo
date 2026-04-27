class Quote < ApplicationRecord
  belongs_to :work_order
  belongs_to :technician
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending approved rejected] }
end
