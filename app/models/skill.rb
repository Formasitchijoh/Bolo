class Skill < ApplicationRecord
  belongs_to :job_category
  has_many :technician_skills, dependent: :destroy
  has_many :technicians, through: :technician_skills
  # This means "Plumbing" can exist under both Plumbing category and HVAC category
  # as separate skills, but two skills can't have the same name within the same category.
  validates :name, presence: true, uniqueness: { scope: :job_category_id }
end
