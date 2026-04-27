class PhoneNumber < ApplicationRecord
  belongs_to :contact
  validates :number, presence: true, format: { with: /\A\+?[0-9]{7,15}\z/, message: "must be a valid phone number" }
  validates :operator, presence: true
end
