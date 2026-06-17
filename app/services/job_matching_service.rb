class JobMatchingService
  CLAIM_WINDOW_MINUTES = 15

  def initialize(job)
    @job = job
  end

  def call
    technicians = find_matched_technicians
    return if technicians.empty?

    ranked = rank_by_proximity(technicians)
    broadcast_to_next(ranked)
  end

  private

  def find_matched_technicians
    # Get skill ids required for this job category
    required_skill_ids = Skill.where(job_category_id: @job.job_category_id).pluck(:id)

    # Find verified technicians who have at least one matching skill
    technicians = Technician
      .where(status: "verified")
      .joins(:technician_skills)
      .where(technician_skills: { skill_id: required_skill_ids })
      .distinct

    # If job is company-specific, filter to that company's technicians first
    if @job.company_id.present?
      company_technicians = technicians.where(company_id: @job.company_id)
      technicians = company_technicians.any? ? company_technicians : technicians
    end

    # Exclude technicians already assigned to this job
    already_assigned_ids = @job.assignments.pluck(:technician_id)
    technicians = technicians.where.not(id: already_assigned_ids)

    technicians
  end

  def rank_by_proximity(technicians)
    technicians
      .select { |t| t.latitude.present? && t.longitude.present? }
      .sort_by { |t| distance_in_km(@job.latitude, @job.longitude, t.latitude, t.longitude) }
  end

  def broadcast_to_next(ranked_technicians)
    return if ranked_technicians.empty?

    technician = ranked_technicians.first

    # Creating a new assignment with status 'pending' for the closest technician
    # This will trigger the notification to the technician via ActiveRecord callbacks
    @job.assignments.create!(
      technician: technician,
      company_id: technician.company_id,
      status: "pending",
      claim_window: Time.current + 10.minutes
    )
  end

  # Haversine formula to calculate distance between two point on the globe using lat/lon
  # https://medium.com/@mattgazzano/the-haversine-formula-a-must-have-for-geospatial-reporting-1a1258552a5e
  def distance_in_km(lat_job, lon_job, lat_tech, lon_tech)
    rad_per_deg = Math::PI / 180
    earth_radius = 6371

    dlat = (lat_tech.to_f - lat_job.to_f) * rad_per_deg
    dlon = (lon_tech.to_f - lon_job.to_f) * rad_per_deg

    a = Math.sin(dlat/2)**2 +
        Math.cos(lat_job.to_f * rad_per_deg) *
        Math.cos(lat_tech.to_f * rad_per_deg) *
        Math.sin(dlon/2)**2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    earth_radius * c
  end
end
