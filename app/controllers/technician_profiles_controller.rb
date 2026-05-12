class TechnicianProfilesController < ApplicationController
  before_action :require_login
  before_action :require_technician

  def edit
    @technician = current_user.technician
    @skills_by_category = Skill.includes(:job_category).all.group_by(&:job_category)
    @selected_skill_ids = @technician.skill_ids # A technician has many skills in the technician_skill table and so calling .skill_ids returns all the related skils to this technician 
  end

  def update
    @technician = current_user.technician

    if @technician.update(technician_params)
      sync_skills
      @technician.update!(status: "verified", verified: true)
      redirect_to dashboard_path, notice: "Profile updated successfully."
    else
      @skills_by_category = Skill.includes(:job_category).all.group_by(&:job_category)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def technician_params
    params.require(:technician).permit(:latitude, :longitude)
  end

  # Synchronize technician's skills based on what they have selected in their profile.
  def sync_skills
    selected_ids = Array(params.dig(:technician, :skill_ids)).map(&:to_i).reject(&:zero?)
    existing_ids = @technician.technician_skills.pluck(:skill_id)

    # Removes the existing skills that are not selected in the new skills list
    # existing_ids - selected_ids  # [1, 2, 3] - [2, 3, 4] = [1]
    # Delete skill with ID [1]
    @technician.technician_skills.where(skill_id: existing_ids - selected_ids).destroy_all

    # Ceate new selected skills that were not initially present
    #  selected_ids - existing_ids  # [2, 3, 4] - [1, 2, 3] = [4]
    #  Create skill with ID [4]
    (selected_ids - existing_ids).each do |skill_id|
      @technician.technician_skills.create!(skill_id: skill_id)
    end
  end
end
