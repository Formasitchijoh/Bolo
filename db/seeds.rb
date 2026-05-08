# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# category = JobCategory.find_by(name: "Plumbing")
# category1 = JobCategory.find_by(name: "HVAC")
# Skill.create!(name: "Pipe fitting", job_category: category)
# Skill.create!(name: "Drain cleaning", job_category: category)
# Skill.create!(name: "Leak repair", job_category: category)
# Skill.create!(name: "Thermostat installation", job_category: category1)
# Skill.create!(name: "Ductwork installation", job_category: category1)


tenant = Tenant.find(1)
Company.create!(tenant: tenant, name: "Bolo", email: "bolo@example.com", status: "active")
