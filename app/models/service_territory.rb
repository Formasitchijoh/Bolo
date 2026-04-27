class ServiceTerritory < ApplicationRecord
  belongs_to :company
  validates :name, presence: true, uniqueness: { scope: :company_id }
end
