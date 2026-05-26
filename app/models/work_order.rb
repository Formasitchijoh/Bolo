class WorkOrder < ApplicationRecord
  belongs_to :assignment
  has_many :quotes, dependent: :destroy
  has_one :rating, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  validates :status, inclusion: { in: %w[on_hold en_route arrived in_progress incomplete completed cancelled] }
end
