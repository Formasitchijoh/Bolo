class JobsController < ApplicationController
  before_action :require_login
  before_action :require_customer, except: [:show]
  before_action :set_form_data, only: [:new, :create]



  def index
    @jobs = Job.where(customer_id: current_user.customer.id)
               .includes(:job_category)
               .with_attached_media
               .order(created_at: :desc)
  end

  def show
    if current_user.customer?
      @job = current_user.customer.jobs
                         .includes(:job_category, :address, assignments: { technician: :user, work_order: :line_items }, media_attachments: :blob)
                         .find(params[:id])
    elsif current_user.technician?
      @job = Job.joins(:assignments)
                .where(assignments: { technician_id: current_user.technician.id })
                .includes(:job_category, :address, assignments: { work_order: :line_items }, media_attachments: :blob)
                .find(params[:id])
    end
    @latest_assignment = @job.assignments.max_by(&:created_at)
    @work_order        = @latest_assignment&.work_order
  end

  def new
    @job = Job.new
  end

  def create
    @address = Address.new(name: params[:address], latitude: params[:latitude], longitude: params[:longitude])
    # This is possible because of the association we have between the Job and the Address models
    # Think of it like assigning an instance of Address to a variable in Job whose type is Address,
    #  And so the assignment will work since they are of the similar type and the address will be saved on saving the job
    # Splatiing more of like spreeading the attributes of the job_params into the new instance of job 
    @job = Job.new(address: @address, **job_params())
    # Get the current user from session to prevent Malicious user submitting any customer_id
    # And creating Jobs on behalf of the customer
    @job.customer = current_user.customer # Getting the associated customer record that is linked to this user 
    if @job.save
      redirect_to jobs_path, notice: "Job created successfully"
    else
      puts @job.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_form_data
    # TODO: check why you are using .all here and if you can use a more efficient query
    # To get only the required data
    @job_categories = JobCategory.all
    @companies = Company.all
  end

  def job_params
    params.require(:job).permit(:company_id, :job_category_id, :title, :latitude, :longitude, :details, :price_range_min, :price_range_max, media: [])
  end
  def address_params
    params.require(:address).permit(:address, :latitude, :longitude)
  end
end
