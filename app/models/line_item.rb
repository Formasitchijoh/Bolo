class LineItem < ApplicationRecord
  belongs_to :work_order
  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end
