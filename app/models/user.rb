class User < ApplicationRecord
  has_one  :tenant
  has_one :customer
  has_one :technician
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password_digest, presence: true
  validates :role, inclusion: { in: %w[customer technician dispatcher company_admin account_owner] }
  validates :status, inclusion: { in: %w[active suspended banned] }
end
