# Job Categories
plumbing = JobCategory.find_or_create_by!(name: "Plumbing")
hvac     = JobCategory.find_or_create_by!(name: "HVAC")

# Skills
pipe_fitting          = Skill.find_or_create_by!(name: "Pipe fitting",           job_category: plumbing)
drain_cleaning        = Skill.find_or_create_by!(name: "Drain cleaning",         job_category: plumbing)
leak_repair           = Skill.find_or_create_by!(name: "Leak repair",            job_category: plumbing)
thermostat_install    = Skill.find_or_create_by!(name: "Thermostat installation", job_category: hvac)
ductwork_install      = Skill.find_or_create_by!(name: "Ductwork installation",   job_category: hvac)

# Account owner + tenant + company
owner = User.find_or_create_by!(email: "owner@bolo.com") do |u|
  u.first_name     = "Bolo"
  u.last_name      = "Owner"
  u.password       = "password123"
  u.role           = "account_owner"
  u.status         = "active"
end

company = Company.find_or_create_by!(name: "Bolo") do |c|
  c.tenant = owner.tenant
  c.email  = "bolo@example.com"
  c.status = "active"
end

# Customer
customer_user = User.find_or_create_by!(email: "customer@bolo.com") do |u|
  u.first_name = "Alice"
  u.last_name  = "Ngo"
  u.password   = "password123"
  u.role       = "customer"
  u.status     = "active"
end

# Technician — fully set up and verified so the matching engine can pick them up
tech_user = User.find_or_create_by!(email: "tech@bolo.com") do |u|
  u.first_name = "Jean"
  u.last_name  = "Mbarga"
  u.password   = "password123"
  u.role       = "technician"
  u.status     = "active"
end

tech = tech_user.technician
tech.update!(
  status:    "verified",
  verified:  true,
  latitude:  3.8480,   # Yaoundé, Cameroon
  longitude: 11.5021
)

TechnicianSkill.find_or_create_by!(technician: tech, skill: pipe_fitting)
TechnicianSkill.find_or_create_by!(technician: tech, skill: drain_cleaning)
TechnicianSkill.find_or_create_by!(technician: tech, skill: leak_repair)
TechnicianSkill.find_or_create_by!(technician: tech, skill: thermostat_install)
TechnicianSkill.find_or_create_by!(technician: tech, skill: ductwork_install)
