class Contact < ApplicationRecord
  belongs_to :contactable, polymorphic: true
  has_many :phone_numbers, dependent: :destroy
end
