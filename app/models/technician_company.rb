class TechnicianCompany < ApplicationRecord
  belongs_to :technician
  belongs_to :company
  # Same reasoning as TechnicianSkill, a technician can only be associated with a company once.
  validates :technician_id, uniqueness: { scope: :company_id }
  scope :for_company, ->(company) { where(company_id: company.id) }
end
