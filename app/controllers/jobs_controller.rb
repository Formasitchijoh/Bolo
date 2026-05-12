class JobsController < ApplicationController
  before_action :require_login
  before_action :require_customer
  before_action :set_form_data, only: [ :new, :create ]



  def index
    @jobs = Job.where(customer_id: current_user&.customer&.id)
  end

  def new
    @job = Job.new
  end

  def create
    @job = Job.new(job_params())
    # Get the current user from session to prevent Malicious user submitting any customer_id
    # And creating Jobs on behalf of the customer
    @job.customer = current_user.customer # Getting the associated customer record that is linked to this user 
    if @job.save
      redirect_to jobs_path, notice: "Job created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_form_data
    @job_categories = JobCategory.all
    @companies = Company.all
  end

  def job_params
    params.require(:job).permit(:company_id, :job_category_id, :title, :latitude, :longitude, :details, :media, :price_range_min, :price_range_max)
  end
end
