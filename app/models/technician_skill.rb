class TechnicianSkill < ApplicationRecord
  belongs_to :technician
  belongs_to :skill
  # Using scope here here restricts a technicians skills to a single skill_id
  # Meaning a technicians can not have the same skills which maps to the same skill_id more thna once.
  validates :technician_id, uniqueness: { scope: :skill_id }
end
