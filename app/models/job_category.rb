class JobCategory < ApplicationRecord
  has_many :jobs, dependent: :nullify
  has_many :skills, dependent: :nullify
  validates :name, presence: true, uniqueness: true
end
