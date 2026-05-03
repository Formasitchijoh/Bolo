class ServiceTerritory < ApplicationRecord
  belongs_to :company
  validates :name, presence: true, uniqueness: { scope: :company_id }
  scope :for_company, ->(company) { where(company_id: company.id) }
end
