class Shift < ApplicationRecord
  belongs_to :company
  belongs_to :technician
  validates :start_time, presence: true
  validates :end_time, presence: true, comparison: { greater_than: :start_time }
  scope :for_company, ->(company) { where(company_id: company.id) }
end
