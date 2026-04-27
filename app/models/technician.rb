class Technician < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  has_many :shifts, dependent: :destroy
  has_many :assignments, dependent: :destroy
  has_many :technician_skills, dependent: :destroy
  has_many :skills, through: :technician_skills
  has_many :ratings, dependent: :destroy
  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :technician_companies, dependent: :destroy
  has_many :companies, through: :technician_companies
  has_many :quotes, dependent: :nullify
  has_many :work_orders, through: :assignments
  validates :verified, inclusion: { in: [true, false] }
  validates :status, inclusion: { in: %w[unverified verified suspended banned in_review] }
end