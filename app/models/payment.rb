class Payment < ApplicationRecord
  belongs_to :work_order
  belongs_to :customer
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending completed failed] }
  validates :reference_id, uniqueness: true, allow_nil: true
end
