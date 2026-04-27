class Company < ApplicationRecord
  belongs_to :tenant
  has_many :technicians, dependent: :nullify
  has_many :service_territories, dependent: :destroy
  has_many :jobs, dependent: :nullify
  has_many :shifts, dependent: :destroy
  has_many :technician_companies, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[active suspended banned] }
end
