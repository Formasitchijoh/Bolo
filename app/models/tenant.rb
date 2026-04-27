class Tenant < ApplicationRecord
  belongs_to :user
  has_many :companies, dependent: :destroy
end
