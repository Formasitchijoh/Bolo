class WorkOrder < ApplicationRecord
  belongs_to :assignment
  has_many :quotes, dependent: :destroy
  has_one :rating, dependent: :destroy
  has_many :line_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many_attached :media
  validates :status, inclusion: { in: %w[on_hold en_route arrived in_progress incomplete completed cancelled quote_submitted quote_approved quote_rejected] }
end
