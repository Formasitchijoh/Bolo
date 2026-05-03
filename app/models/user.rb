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
  has_secure_password
  # Rails automatically:
  # - Hashes passwords with bcrypt (cost factor 12)
  # - Adds password and password_confirmation attributes
  # - Validates password presence on create
  # - Provides authenticate(password) method

  def customer?
    role == "customer"
  end

  def technician?
    role == "technician"
  end

  def dispatcher?
    role == "dispatcher"
  end

  def company_admin?
    role == "company_admin"
  end

  def account_owner?
    role == "account_owner"
  end
end
