class Customer < ApplicationRecord
  belongs_to :user
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :jobs, dependent: :nullify
  has_many :ratings
  has_many :payments
  has_many :contacts, as: :contactable, dependent: :destroy
  validates :status, inclusion: { in: %w[good_standing flagged cancelled] }
end
